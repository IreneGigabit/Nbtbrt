<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>
<%@ Register Src="~/commonForm/brta211form.ascx" TagPrefix="uc1" TagName="brta211form" %>
<%@ Register Src="~/commonForm/brt15form.ascx" TagPrefix="uc1" TagName="brt15form" %>
<%@ Register Src="~/commonForm/brt511form.ascx" TagPrefix="uc1" TagName="brt511form" %>
<%@ Register Src="~/commonForm/brta311form.ascx" TagPrefix="uc1" TagName="brta311form" %>
<%@ Register Src="~/commonForm/brta321form.ascx" TagPrefix="uc1" TagName="brta321form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/brta34form.ascx" TagPrefix="uc1" TagName="brta34form" %>

<script runat="server">
    protected string HTProgCap = "國內案件進度查詢作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string HTProgCap_subtitle = "";
    protected string submitTask = "";
    protected string json = "";
    protected string rs_no = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string cgrs = "";
    protected string cg = "";
    protected string rs = "";

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

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = ReqVal.TryGet("submittask").ToUpper();
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        if (ReqVal.TryGet("type") == "brtran") {
            conn = new DBHelper(Conn.brp(Request["branch"])).Debug(Request["chkTest"] == "TEST");
            HTProgCap_subtitle = "轉案單位案件資料";
        }
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        json = (Request["json"] ?? "").Trim().ToUpper();
        rs_no = ReqVal.TryGet("rs_no");
        seq = ReqVal.TryGet("seq");
        seq1 = ReqVal.TryGet("seq1");
        cgrs = ReqVal.TryGet("cgrs");
        cg = ReqVal.TryGet("cgrs").Left(1);
        rs = ReqVal.TryGet("cgrs").Right(1);
        
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
        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
            Lock["Qdisabled_opt"] = "Lock";
        }

        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>" + HTProgCap_subtitle + "查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
                if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                    StrFormBtn += "<input type=button id='button1' value='存　檔' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
                }
                if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                    StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onClick='formDelSubmit()'>\n";
                }
                StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        brta211form.Lock = new Dictionary<string, string>(Lock);//官收欄位畫面
        brt15form.Lock = new Dictionary<string, string>(Lock);//後續交辦紀錄欄位畫面
        brt511form.Lock = new Dictionary<string, string>(Lock);//客收欄位畫面
        brta311form.Lock = new Dictionary<string, string>(Lock);//官發欄位畫面
        brta321form.Lock = new Dictionary<string, string>(Lock);//客發欄位畫面
        brta34form.Lock = new Dictionary<string, string>(Lock);//本發欄位畫面
        Brta212form.Lock = new Dictionary<string, string>(Lock);//管制欄位畫面
    }

    private void QueryData() {
        Dictionary<string, string> step_data = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        //管制資料
        DataTable dtCtrl = new DataTable();
        //總管處官收電子公文檔
        DataTable dtMGAttach = new DataTable();
        //官收自行客戶報導文件
        DataTable dtGRAttach = new DataTable();
        //對應客收交辦
        DataTable dtCaseCR = new DataTable();
        //客收規費明細
        DataTable dtFees = new DataTable();

        if (submitTask == "Q") {
            SQL = "Select * From vstep_dmt Where RS_No = '" + Request["rs_no"] + "'";
            DataTable dtStep = new DataTable();
            conn.DataTable(SQL, dtStep);

            if (dtStep.Rows.Count > 0) {
                DataRow dr = dtStep.Rows[0];

                //怕漏欄位
                step_data = dr.Table.Columns.Cast<DataColumn>()
                .ToDictionary(col => col.ColumnName, col => dr.SafeRead(col.ColumnName, ""));

                step_data["rs_sqlno"] = dr.SafeRead("rs_sqlno", "");
                step_data["rs_no"] = dr.SafeRead("rs_no", "");
                step_data["branch"] = dr.SafeRead("branch", "");
                step_data["seq"] = dr.SafeRead("seq", "");
                step_data["seq1"] = dr.SafeRead("seq1", "");
                step_data["fseq"] = Sys.formatSeq(step_data["seq"], step_data["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                step_data["cg"] = dr.SafeRead("cg", "");
                step_data["rs"] = dr.SafeRead("rs", "");
                step_data["step_grade"] = dr.SafeRead("step_grade", "");
                step_data["nstep_grade"] = dr.SafeRead("step_grade", "");
                step_data["cgrs"] = dr.SafeRead("cg", "") + dr.SafeRead("rs", "");
                step_data["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                step_data["mp_date"] = dr.GetDateTimeString("mp_date", "yyyy/M/d");
                step_data["send_cl"] = dr.SafeRead("send_cl", "");
                step_data["send_cl1"] = dr.SafeRead("send_cl1", "");
                step_data["send_sel"] = dr.SafeRead("send_sel", "");
                step_data["receive_no"] = dr.SafeRead("receive_no", "");
                step_data["receive_way"] = dr.SafeRead("receive_way", "");
                step_data["rs_type"] = Sys.getRsType();
                step_data["rs_class"] = dr.SafeRead("rs_class", "");
                step_data["rs_code"] = dr.SafeRead("rs_code", "");
                step_data["act_code"] = dr.SafeRead("act_code", "");
                step_data["oact_code"] = dr.SafeRead("act_code", "");
                step_data["receipt_type"] = dr.SafeRead("receipt_type", "");
                step_data["receipt_title"] = dr.SafeRead("receipt_title", "");
                step_data["send_way"] = dr.SafeRead("send_way", "");

                //取得結構分類、代碼、處理事項名稱
                SQL = "select code_name from cust_code where code_type='" + step_data["rs_type"] + "' and cust_code='" + step_data["rs_class"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                step_data["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                SQL = "select rs_detail from code_br where rs_type='" + step_data["rs_type"] + "' and rs_code='" + step_data["rs_code"] + "' and gr='Y' ";
                objResult = conn.ExecuteScalar(SQL);
                step_data["rs_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                SQL = "select code_name from cust_code where code_type='tact_code' and cust_code='" + step_data["act_code"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                step_data["act_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                //取得案件狀態
                SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
                SQL += "from vcode_act ";
                SQL += "where rs_code = '" + step_data["rs_code"] + "' ";
                SQL += "and act_code = '" + step_data["act_code"] + "' ";
                SQL += "and rs_type = '" + step_data["rs_type"] + "'";
                SQL += "and cg = '" + step_data["cg"] + "'";
                SQL += "and rs = '" + step_data["rs"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        step_data["ocase_stat"] = dr0.SafeRead("case_stat", "");
                        step_data["case_stat"] = dr0.SafeRead("case_stat", "");
                        step_data["case_statnm"] = dr0.SafeRead("case_stat_name", "");
                        step_data["ncase_stat"] = dr0.SafeRead("case_stat", "");
                        step_data["ncase_statnm"] = dr0.SafeRead("case_stat_name", "");
                    }
                }
                step_data["rs_detail"] = dr.SafeRead("rs_detail", "");
                step_data["doc_detail"] = dr.SafeRead("doc_detail", "");
                step_data["cs_rs_no"] = dr.SafeRead("cs_rs_no", "");
                step_data["cs_detail"] = "";
                if (step_data["cs_rs_no"] != "") {
                    SQL = " select rs_no,rs_detail,send_way,print_date,mail_date,mail_scode,mwork_date";
                    SQL += ",(select sc_name from sysctrl.dbo.scode where scode=mail_scode) as mail_scname ";
                    SQL += "from cs_dmt ";
                    SQL += "where rs_no = '" + step_data["cs_rs_no"] + "' ";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {
                            step_data["cs_detail"] = dr0.SafeRead("rs_detail", "");
                            step_data["send_way"] = dr0.SafeRead("send_way", "");
                            step_data["print_date"] = dr0.SafeRead("print_date", "");
                            step_data["mail_date"] = dr0.GetDateTimeString("mail_date", "yyyy/M/d");
                            step_data["mail_scode"] = dr0.SafeRead("mail_scode", "");
                            step_data["mail_scname"] = dr0.SafeRead("mail_scname", "");
                            step_data["mwork_date"] = dr0.SafeRead("mwork_date", "");
                        }
                    }
                }

                step_data["fees"] = dr.SafeRead("fees", "0");
                step_data["fees_stat"] = dr.SafeRead("fees_stat", "");
                step_data["case_no"] = dr.SafeRead("case_no", "");
                step_data["pr_scode"] = dr.SafeRead("pr_scode", "");
                step_data["opt_branch"] = dr.SafeRead("opt_branch", "");
                step_data["opt_stat"] = dr.SafeRead("opt_stat", "");
                step_data["pr_scan"] = dr.SafeRead("pr_scan", "");
                step_data["pr_scan_page"] = dr.SafeRead("pr_scan_page", "");
                step_data["pr_scan_path"] = dr.SafeRead("pr_scan_path", "");
                step_data["pr_scan_remark"] = dr.SafeRead("pr_scan_remark", "");
                step_data["csd_flag"] = dr.SafeRead("csd_flag", "");
                step_data["cs_remark"] = dr.SafeRead("cs_remark", "");
                step_data["pmail_date"] = dr.GetDateTimeString("pmail_date", "yyyy/M/d");
                step_data["rs_agt_no"] = dr.SafeRead("rs_agt_no", "");
                step_data["rs_agt_nonm"] = "";

                //取得發文出名代理人
                SQL = "select treceipt+'_'+agt_name from agt where agt_no='" + step_data["rs_agt_no"] + "'";
                objResult = conn.ExecuteScalar(SQL);
                step_data["rs_agt_nonm"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                //抓取官收營洽確認資料
                SQL = "select * from grconf_dmt where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"];
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        step_data["cs_flag"] = dr0.SafeRead("cs_flag", "");
                        step_data["scs_detail"] = dr0.SafeRead("scs_detail", "");
                        step_data["cs_send_way"] = dr0.SafeRead("cs_send_way", "");
                        step_data["last_date"] = dr0.GetDateTimeString("last_date", "yyyy/M/d");
                        step_data["pstep_date"] = dr0.GetDateTimeString("pstep_date", "yyyy/M/d");
                        step_data["job_type"] = dr0.SafeRead("job_type", "");
                        step_data["job_case"] = dr0.SafeRead("job_case", "");
                        step_data["pre_date"] = dr0.GetDateTimeString("pre_date", "yyyy/M/d");
                        step_data["sales_remark"] = dr0.SafeRead("sales_remark", "");
                        step_data["cs_report"] = dr0.SafeRead("cs_report", "");
                        step_data["job_no"] = dr0.SafeRead("job_no", "");
                    }
                }

                //抓取文件掃描資料
                //因電子收文有公文檔，所以掃描不一定放第一順位，改用order by抓第一筆掃描資料
                SQL = " select chk_page,attach_path,attach_desc from dmt_attach where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"] + " and source='scan' and chk_status like 'Y%' order by attach_no ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        step_data["pr_scan"] = "Y";
                        step_data["pr_scan_page"] = dr0.SafeRead("chk_page", "");
                        step_data["pr_scan_path"] = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                        step_data["pr_scan_remark"] = dr0.SafeRead("attach_desc", "");
                    }
                }

                //取得總收發文收文內容
                step_data["mg_rs_detail"] = "";
                if (dr.SafeRead("mg_rs_sqlno", "") != "") {
                    SQL = " select rs_detail from step_mgt_temp where mg_step_rs_sqlno='" + dr.SafeRead("mg_rs_sqlno", "") + "' ";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {
                            step_data["mg_rs_detail"] = dr0.SafeRead("rs_detail", "");
                        }
                    }
                }

                //取得官收時智慧局電子公文檔
                step_data["pdfsource"] = "GR";
                //2019/6/18修改，電子公文receive_way=R9其source=EGR，其餘皆為GR，路徑只有電子公文會不同須判斷，其餘都直接連到總管處顯示
                if (step_data["receive_way"] == "R9") {//R9_電子公文
                    step_data["pdfsource"] = "EGR";
                }
                SQL = "select attach_path,attach_name,source,''view_path ";
                SQL += " from dmt_attach ";
                SQL += "where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"];
                SQL += "  and source='" + step_data["pdfsource"] + "' and attach_flag<>'D' ";
                SQL += "order by attach_sqlno ";
                conn.DataTable(SQL, dtMGAttach);
                for (int i = 0; i < dtMGAttach.Rows.Count; i++) {
                    DataRow dr0 = dtMGAttach.Rows[i];
                    string attach_path = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                    string viewserver = "http://" + Sys.Host;

                    //若區所主機找不到就找總所主機
                    if (Sys.CheckFile(attach_path) == false) {
                        viewserver = "http://" + Sys.MG_IIS;
                        if (step_data["pdfsource"] == "EGR") {
                            attach_path = Sys.Path2MG(attach_path);
                        }
                    }
                    dr0["attach_path"] = attach_path;
                    dr0["view_path"] = viewserver + attach_path;
                }

                //取得官收確認自行客戶報導文件
                SQL = "select *,''view_path from dmt_attach where seq='" + seq + "' and seq1='" + seq1 + "' and step_grade=" + step_data["nstep_grade"] + " and source='grconf_cs' and attach_flag<>'D' order by attach_sqlno ";
                conn.DataTable(SQL, dtGRAttach);
                for (int i = 0; i < dtGRAttach.Rows.Count; i++) {
                    DataRow dr0 = dtGRAttach.Rows[i];
                    string attach_path = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                    string viewserver = "http://" + Sys.Host;

                    dr0["attach_path"] = attach_path;
                    dr0["view_path"] = viewserver + attach_path;
                }

                //取得本發時對應客收交辦
                DataTable dtStepCR = Sys.StepDmt(conn, step_data["seq"], step_data["seq1"], "and zs_rs_sqlno='" + dr.SafeRead("rs_sqlno", "") + "'");
                if (dtStepCR.Rows.Count > 0) {
                    dtCaseCR = Sys.GetCaseDmtMain(conn, seq, seq1, dtStepCR.Rows[0].SafeRead("case_no", ""));
                }

                //抓取客收規費明細
                SQL = " select a.rs_no,a.case_no,a.fees,b.arcase,b.arcase_type,b.arcase_class,(b.fees+b.add_fees) as case_fees,b.change";
                SQL += ",b.gs_fees,(b.service+b.add_service) as service,b.ar_mark,b.gs_curr,c.agt_no";
                SQL += ",(select agt_name from agt where agt_no=c.agt_no) as agt_name";
                SQL += ",(select treceipt from agt where agt_no=c.agt_no) as receipt";
                SQL += ",(SELECT rs_detail FROM code_br WHERE rs_type=b.arcase_type and rs_code=b.arcase AND dept= 'T' AND gs='Y') as arcasenm";
                SQL += ",(select code_name from cust_code where code_type='AR_MARK' and cust_code = b.ar_mark) as ar_marknm";
                SQL += " from fees_dmt a,case_dmt b,dmt_temp c where rs_no='" + step_data["rs_no"] + "'";
                SQL += " and a.case_no = b.case_no and b.in_no=c.in_no and c.case_sqlno=0";
                SQL += " order by a.case_no";
                conn.DataTable(SQL, dtFees);
                
                //管制資料
                SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
                SQL += " where rs_no='" + step_data["rs_no"] + "'";
                SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
                SQL += " where rs_no='" + step_data["rs_no"] + "'";
                SQL += " order by ctrl_date";
                conn.DataTable(SQL, dtCtrl);
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
        Response.Write(",\"step_data\":" + JsonConvert.SerializeObject(step_data, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"mg_attach\":" + JsonConvert.SerializeObject(dtMGAttach, settings).ToUnicode() + "\n");//總管處官收電子公文檔
        Response.Write(",\"gr_attach\":" + JsonConvert.SerializeObject(dtGRAttach, settings).ToUnicode() + "\n");//官收確認自行客戶報導文件
        Response.Write(",\"cr_case\":" + JsonConvert.SerializeObject(dtCaseCR, settings).ToUnicode() + "\n");//本發時對應客收交辦
        Response.Write(",\"fees\":" + JsonConvert.SerializeObject(dtFees, settings).ToUnicode() + "\n");//規費明細
        Response.Write(",\"ctrl_data\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
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
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
		案件編號：<span id="span_fseq"></span>
        &nbsp;&nbsp;<span id="span_rs_no"><font color=blue><%=(rs=="R"?"收文":"發文")%></font>序號：<%=rs_no%></span>
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
    <INPUT TYPE="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id="seq" name=seq value="<%=seq%>">
    <INPUT TYPE="hidden" id="seq1" name=seq1 value="<%=seq1%>">
    <div style="width:98%;text-align:center">
        <%if(cgrs=="GR"){%>
            <uc1:brta211form runat="server" ID="brta211form" /><!--官收欄位畫面-->
            <uc1:brt15form runat="server" ID="brt15form" /><!--後續交辦紀錄欄位畫面--> 
        <%}else if(cgrs=="CR"){%>
            <uc1:brt511form runat="server" ID="brt511form" /><!--客收欄位畫面-->
        <%}else if(cgrs=="GS"){%>
            <uc1:brta311form runat="server" ID="brta311form" /><!--官發欄位畫面-->
        <%}else if(cgrs=="CS"){%>
            <uc1:brta321form runat="server" ID="brta321form" /><!--客發欄位畫面-->
        <%}else if(cgrs=="ZS"){%>
            <uc1:brta34form runat="server" ID="brta34form" /><!--本發欄位畫面-->
        <%}%>
        <uc1:Brta212form runat="server" ID="Brta212form" /><!--管制欄位畫面-->
     </div>

    <br>
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
<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
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
        //取得收文資料
        $.ajax({
            type: "get",
            url: "brta61_QStep.aspx?json=Y&<%#Request.QueryString%>",
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        //畫面準備
        if (typeof brta211form !== "undefined") brta211form.init();//官收欄位綁定
        if (typeof brt15form !== "undefined") brt15form.init();//後續交辦紀錄/自行客戶報導欄位綁定
        if (typeof brt511form !== "undefined") brt511form.init();//客收欄位綁定
        if (typeof brta311form !== "undefined") brta311form.init();//官發資料/交辦明細欄位綁定
        if (typeof brta321form !== "undefined") brta321form.init();//客發欄位綁定
        if (typeof brta34form !== "undefined") brta34form.init();//本發文資料/對應客收交辦
        brta212form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定


        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#span_fseq").html(jMain.step_data.fseq);

        if (typeof brta211form !== "undefined") brta211form.bind(jMain.step_data,jMain.mg_attach);//官收欄位綁定
        if (typeof brt15form !== "undefined") brt15form.bind(jMain.step_data,jMain.gr_attach);//後續交辦紀錄/自行客戶報導欄位綁定
        if (typeof brt511form !== "undefined") brt511form.bind(jMain.step_data);//客收欄位綁定
        if (typeof brta311form !== "undefined") brta311form.bind(jMain.step_data,jMain.fees);//官發資料/交辦明細欄位綁定
        if (typeof brta321form !== "undefined") brta321form.bind(jMain.step_data);//客發欄位綁定
        if (typeof brta34form !== "undefined") brta34form.bind(jMain.step_data,jMain.cr_case);//本發文資料/對應客收交辦
        brta212form.bind(jMain.step_data,jMain.ctrl_data);//管制資料

        if($("#cgrs").val()=="CR"){
            if(jMain.step_data.opt_stat!=""){
                $("#show_optstat,#sp_optstat").show();//爭救案交辦
            }
        }

        if($("#cgrs").val()=="GR"){
            $("#tr_csmail_date").show();//客函寄出日期
        }
    }
</script>

