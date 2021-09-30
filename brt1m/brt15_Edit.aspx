<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brta211form.ascx" TagPrefix="uc1" TagName="brta211form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/brt15form.ascx" TagPrefix="uc1" TagName="brt15form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案官方收文營洽確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string submitTask = "";
    protected string json = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string step_grade = "";

    protected string se_grpid = "", mSC_code = "", mSC_name = "", html_selectsign = "";

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
        step_grade = ReqVal.TryGet("step_grade","0");
        
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
        Lock["Qdisabled"] = "Lock";

        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";

        if (submitTask == "U" && prgid == "brt152") {
            FormName = "備註:<br>\n";
            FormName += "1.作業處理不能修改，表示已洽案<br>\n";
        }

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0 || (HTProgRight & 128) > 0) {
                if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                    //20161212官發確認時增加電子申請書word檢查
                    if (prgid == "brt15") {
                        StrFormBtn += "<input type=button id='button0' value='確認交辦' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
                    } else if (prgid == "brt152") {
                        StrFormBtn += "<input type=button id='button0' value='編修存檔' class='cbutton bsubmit' onClick='formAddSubmit()'>\n";
                    }
                }
                if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                    StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onClick='formDelSubmit()'>\n";
                }
                StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }
        
        //正常簽核
        mSC_code = Sys.getSignMaster(Sys.GetSession("SeBranch"), ReqVal.TryGet("qryscode", Sys.GetSession("scode")), false);
        SQL = "select sc_name from scode where scode='" + mSC_code + "'";
        object objResult = cnn.ExecuteScalar(SQL);
        mSC_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

        //特殊簽核
        DataRow[] drx = Sys.getGrpidUp(Sys.GetSession("SeBranch"), "000").Select("grplevel<=1 and grplevel>-1");
        html_selectsign = drx.Option("{master_scode}", "{master_type}---{master_nm}", false);
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta21form.Lock = new Dictionary<string, string>(Lock);
        Brta211form.Lock = new Dictionary<string, string>(Lock);
        Brta212form.Lock = new Dictionary<string, string>(Lock);
        Brt15form.Lock = new Dictionary<string, string>(Lock);
    }

    private void QueryData() {
        Dictionary<string, string> add_gr = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        
        SQL = "select a.*,c.branch,c.cappl_name as appl_name,c.csd_flag as scsd_flag,c.cs_remark,c.pmail_date";
        SQL += ",c.step_date,c.mp_date,c.rs_detail,c.rs_no,c.cg,c.rs,c.send_cl,c.rs_class,c.rs_code,c.act_code";
        SQL += ",c.doc_detail,c.mg_rs_sqlno,c.receive_no,c.receive_way,c.pr_scode,c.pr_scan,c.pr_scan_page,c.pr_scan_remark,c.pr_scan_path";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode=c.dmt_scode) as sc_name,c.cust_prod";
        SQL += ",''fseq,''nstep_grade,''cs_detail,''send_way,''print_date,''mail_date";
        SQL += " from grconf_dmt a ";
        SQL += " inner join vstep_dmt c on a.seq=c.seq and a.seq1=c.seq1 and a.step_grade=c.step_grade and a.rs_sqlno=c.rs_sqlno ";
        SQL += " where a.seq=" + seq + " and a.seq1='" + seq1 + "' and a.step_grade=" + step_grade;
        DataTable dtGrConfDmt = new DataTable();
        conn.DataTable(SQL, dtGrConfDmt);

        //管制資料
        DataTable dtCtrl = new DataTable();

        add_gr["seq"] = seq;
        add_gr["seq1"] = seq1;
        add_gr["fseq"] = Sys.formatSeq(seq, seq1, "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

        if (dtGrConfDmt.Rows.Count > 0) {
            DataRow dr = dtGrConfDmt.Rows[0];

            SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
            SQL+= " where rs_no='" +dr.SafeRead("rs_no", "")+ "'";
            SQL+= " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
            SQL+= " where rs_no='" +dr.SafeRead("rs_no", "")+ "'";
            SQL+= " order by ctrl_date";
            conn.DataTable(SQL, dtCtrl);

            add_gr["grconf_sqlno"] = dr.SafeRead("grconf_sqlno", "");
            add_gr["rs_sqlno"] = dr.SafeRead("rs_sqlno", "");
            add_gr["rs_no"] = dr.SafeRead("rs_no", "");
            add_gr["branch"] = dr.SafeRead("branch", "");
            add_gr["nstep_grade"] = dr.SafeRead("step_grade", "");
            add_gr["cgrs"] = dr.SafeRead("cg", "") + dr.SafeRead("rs", "");
            add_gr["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
            add_gr["mp_date"] = dr.GetDateTimeString("mp_date", "yyyy/M/d");
            add_gr["send_cl"] = dr.SafeRead("send_cl", "");
            add_gr["ssend_cl"] = dr.SafeRead("send_cl", "");
            add_gr["receive_no"] = dr.SafeRead("receive_no", "");
            add_gr["receive_way"] = dr.SafeRead("receive_way", "");
            add_gr["rs_type"] = Sys.getRsType();
            add_gr["rs_class"] = dr.SafeRead("rs_class", "");
            add_gr["rs_code"] = dr.SafeRead("rs_code", "");
            add_gr["act_code"] = dr.SafeRead("act_code", "");
            //取得案件狀態
            SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
            SQL += "from vcode_act ";
            SQL += "where rs_code = '" + add_gr["rs_code"] + "' ";
            SQL += "and act_code = '" + add_gr["act_code"] + "' ";
            SQL += "and rs_type = '" + add_gr["rs_type"] + "'";
            SQL += "and cg = 'G' and rs = 'R'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    add_gr["ocase_stat"] = dr0.SafeRead("case_stat", "");
                    add_gr["ncase_stat"] = dr0.SafeRead("case_stat", "");
                    add_gr["ncase_statnm"] = dr0.SafeRead("case_stat_name", "");
                }
            }
            add_gr["rs_detail"] = dr.SafeRead("rs_detail", "");
            add_gr["doc_detail"] = dr.SafeRead("doc_detail", "");
            add_gr["cs_rs_no"] = dr.SafeRead("cs_rs_no", "");
            if (dr.SafeRead("cs_rs_no", "") != "") {
                SQL = "select rs_no,rs_detail,send_way,print_date,mail_date,(select sc_name from sysctrl.dbo.scode where scode=mail_scode) as mail_scname,mwork_date from cs_dmt where rs_no='" + dr["cs_rs_no"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_gr["cs_detail"] = dr0.SafeRead("rs_detail", "");
                        add_gr["send_way"] = dr0.SafeRead("send_way", "");
                        add_gr["print_date"] = dr0.SafeRead("print_date", "");
                        add_gr["mail_date"] = dr0.GetDateTimeString("mail_date", "yyyy/M/d");
                        add_gr["mail_scname"] = dr0.SafeRead("mail_scname", "");
                        add_gr["mwork_date"] = dr0.SafeRead("mwork_date", "");
                    }
                }
            }

            add_gr["pr_scode"] = dr.SafeRead("pr_scode", "");
            add_gr["pr_scan"] = dr.SafeRead("pr_scan", "");
            add_gr["pr_scan_page"] = dr.SafeRead("pr_scan_page", "");
            add_gr["pr_scan_remark"] = dr.SafeRead("pr_scan_remark", "");
            add_gr["pr_scan_path"] = Sys.Path2Nbtbrt(dr.SafeRead("pr_scan_path", ""));
            //掃描文件改入dmt_attach，所以掃描資料要抓dmt_attach
            SQL = "select chk_status,chk_page,attach_path,attach_desc from dmt_attach where seq=" + seq + " and seq1='" + seq1 + "' and step_grade=" + add_gr["nstep_grade"] + " and source='scan'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    add_gr["pr_scan_page"] = dr0.SafeRead("chk_page", "");
                    add_gr["pr_scan_remark"] = dr0.SafeRead("attach_desc", "");
                    add_gr["pr_scan_path"] = Sys.Path2Nbtbrt(dr0.SafeRead("attach_path", ""));
                    if (dr0.SafeRead("chk_status", "") == "NN") {
                        add_gr["pr_scan_path"] = "";
                    }
                }
            }

            //取得總收發文收文內容
            SQL = "select rs_detail from step_mgt_temp where mg_step_rs_sqlno='" + dr["mg_rs_sqlno"] + "'";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    add_gr["mg_rs_detail"] = dr0.SafeRead("rs_detail", "");
                }
            }

            //營洽確認之後續交辦畫面資料
            add_gr["cs_flag"] = dr.SafeRead("cs_flag", "");
            add_gr["scs_detail"] = dr.SafeRead("scs_detail", "");
            add_gr["cs_send_way"] = dr.SafeRead("cs_send_way", "");
            add_gr["last_date"] = dr.GetDateTimeString("last_date", "yyyy/M/d");
            //add_gr["sales_csd_flag"] = dr.SafeRead("csd_flag", "");
            //add_gr["csd_remark"] = dr.SafeRead("csd_remark", "");
            add_gr["pstep_date"] = dr.GetDateTimeString("pstep_date", "yyyy/M/d");
            add_gr["job_type"] = dr.SafeRead("job_type", "");
            add_gr["job_case"] = dr.SafeRead("job_case", "");
            add_gr["pre_date"] = dr.GetDateTimeString("pre_date", "yyyy/M/d");
            add_gr["sales_remark"] = dr.SafeRead("sales_remark", "");
            add_gr["cs_report"] = dr.SafeRead("cs_report", "");
            add_gr["job_no"] = dr.SafeRead("job_no", "");
            //add_gr["finish_date"] = dr.GetDateTimeString("finish_date", "yyyy/M/d");
            //客戶報導資料
            add_gr["csd_flag"] = dr.SafeRead("scsd_flag", "");
            add_gr["cs_remark"] = dr.SafeRead("cs_remark", "");
            add_gr["pmail_date"] = dr.GetDateTimeString("pmail_date", "yyyy/M/d");
            //20170828增加客戶卷號
            //add_gr["cust_prod"] = dr.SafeRead("cust_prod", "");
        }

        add_gr["pdfsource"] = "GR";
        //2019/6/18修改，電子公文rsreive_way=R9其source=EGGR，其餘皆為GR，路徑只有電子公文會不同須判斷，其餘都直接連到總管處顯示
        if (add_gr["receive_way"] == "R9") {//R9_電子公文
            add_gr["pdfsource"] = "EGR";
        }

        //2019/6/20因官收作業進入無案件編號  
        DataTable dtMGAttach = new DataTable();
        if (seq != "" && seq != "0") {
            SQL = "select attach_path,attach_name,source,''view_path from dmt_attach where seq=" + seq + " and seq1='" + seq1 + "' and step_grade=" + add_gr["nstep_grade"] + " and source='" + add_gr["pdfsource"] + "' and attach_flag<>'D' order by attach_sqlno ";
            conn.DataTable(SQL, dtMGAttach);
            for (int i = 0; i < dtMGAttach.Rows.Count; i++) {
                DataRow dr = dtMGAttach.Rows[i];
                string attach_path = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
                string viewserver = "http://" + Sys.Host;

                //若區所主機找不到就找總所主機
                if (Sys.CheckFile(attach_path) == false) {
                    viewserver = "http://" + Sys.MG_IIS;
                    if (add_gr["pdfsource"] == "EGR") {
                        attach_path = Sys.Path2MG(attach_path);
                    }
                }
                dr["attach_path"] = attach_path;
                dr["view_path"] = viewserver + attach_path;
            }
        }

        //官收確認自行客戶報導文件
        DataTable dtGRAttach = new DataTable();
        SQL = "select *,''view_path from dmt_attach where seq='" + seq + "' and seq1='" + seq1 + "' and step_grade=" + add_gr["nstep_grade"] + " and source='grconf_cs' and attach_flag<>'D' order by attach_sqlno ";
        conn.DataTable(SQL, dtGRAttach);
        for (int i = 0; i < dtGRAttach.Rows.Count; i++) {
            DataRow dr = dtGRAttach.Rows[i];
            string attach_path = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
            string viewserver = "http://" + Sys.Host;

            //若區所主機找不到就找總所主機
            if (Sys.CheckFile(attach_path) == false) {
                if (add_gr["pdfsource"] == "EGR") {
                    viewserver = "http://" + Sys.MG_IIS;
                    attach_path = Sys.Path2MG(attach_path);
                }
            }
            dr["attach_path"] = attach_path;
            dr["view_path"] = viewserver + attach_path;
        }

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"add_gr\":" + JsonConvert.SerializeObject(add_gr, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"gr_ctrl\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
        Response.Write(",\"mg_attach\":" + JsonConvert.SerializeObject(dtMGAttach, settings).ToUnicode() + "\n");//總管處官收電子公文檔
        Response.Write(",\"gr_attach\":" + JsonConvert.SerializeObject(dtGRAttach, settings).ToUnicode() + "\n");//官收確認自行客戶報導文件
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
    main.in_no = "<%#ReqVal.TryGet("in_no")%>";
    main.in_scode = "<%#ReqVal.TryGet("in_scode")%>";
    main.task = "<%#ReqVal.TryGet("task")%>";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
            &nbsp;&nbsp;<span id="span_rs_no"></span>
		<img src="<%=Page.ResolveUrl("~/images/icon1.gif")%>" style="cursor:pointer" align="absmiddle" title="期限管制" WIDTH="20" HEIGHT="20" onclick="dmt_IMG_Click(1)">&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon2.gif")%>" style="cursor:pointer" align="absmiddle" title="收發進度" WIDTH="25" HEIGHT="20" onclick="dmt_IMG_Click(2)">&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon4.gif")%>" style="cursor:pointer" align="absmiddle" title="交辦內容" WIDTH="18" HEIGHT="18" onclick="dmt_IMG_Click(4)">&nbsp;
		案件編號：<span id="span_fseq"></span>
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
    <INPUT TYPE="hidden" id=ctrl_flg name=ctrl_flg value="N"><!--判斷有無預設期限管制 N:無,Y:有-->
    <INPUT TYPE="hidden" id=havectrl name=havectrl value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <INPUT TYPE="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id=grconf_sqlno name=grconf_sqlno>
    <INPUT TYPE="hidden" id=rs_sqlno name=rs_sqlno>

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab">
                <td class="tab" href="#grstep">案件暨進度資料</td>
                <td class="tab" href="#grconf">後續交辦紀錄</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#grstep">
                <uc1:Brta21form runat="server" id="Brta21form" /><!--案件主檔欄位畫面，與收文共同-->
                <uc1:brta211form runat="server" id="Brta211form" /><!--官收欄位畫面-->
                <uc1:Brta212form runat="server" id="Brta212form" /><!--管制欄位畫面，與收文共同-->
            </div>
            <div class="tabCont" id="#grconf">
                <uc1:brt15form runat="server" id="Brt15form" /><!--後續交辦紀錄欄位畫面-->
            </div>
       </td>
    </tr>
    </table>

    <div id="div_sign" style="display:none">
        <br>
        <table id="tabhd1" border="0" width="70%" cellspacing="1" cellpadding="0" align="center" style="font-size: 9pt">
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
		        <td style="display:none">
                    <input type=radio name=Osign disabled onclick="$('#usesign2').prop('checked',true)">
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
        settab("#grconf");

        //取得收文資料
        $.ajax({
            type: "get",
            url: "brt15_edit.aspx?json=Y&<%#Request.QueryString%>",
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
        brt15form.init();
        
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定

        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#grconf_sqlno").val(jMain.add_gr.grconf_sqlno);
        $("#rs_sqlno").val(jMain.add_gr.rs_sqlno);

        brta21form.bind(jMain.add_gr);//主檔資料
        brta211form.bind(jMain.add_gr,jMain.mg_attach);//收文資料
        brta212form.bind(jMain.add_gr,jMain.gr_ctrl);//管制資料
        brt15form.bind(jMain.add_gr,jMain.gr_attach);//後續交辦紀錄/自行客戶報導

        $("#tr_csmail_date").show();
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }

    //存檔
    function formAddSubmit(){
        if(chkNull("本所編號",$("#seq"))) return false;
        if(chkNull("本所編號副碼",$("#seq1"))) return false;
        if(chkNull("案性代碼",$("#rs_code"))) return false;
        if(chkNull("處理事項",$("#act_code"))) return false;
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

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var url="";
        if($("#prgid").val()=="brt15"){
            url="Brt15_Update.aspx";
        }else if($("#prgid").val()=="brt152"){
            url="Brt152_Update.aspx";
        }

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

    function toselect() {
        $("input[name=Osign]").prop("checked",false);
    }
</script>

