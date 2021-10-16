<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/Brta21form.ascx" TagPrefix="uc1" TagName="Brta21form" %>
<%@ Register Src="~/commonForm/brta211form.ascx" TagPrefix="uc1" TagName="brta211form" %>
<%@ Register Src="~/commonForm/Brta212form.ascx" TagPrefix="uc1" TagName="Brta212form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案官方收文作業";//HttpContext.Current.Request["prgname"];//功能名稱
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
            Lock["Qdisabled"] = "Lock";
        }

        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        if (cgrs == "CR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta4m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>\n";
        if (cgrs == "GR") StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brtam/brta4m.aspx") + "?prgid=brta41m&cgrs=" + cgrs + "\" target=\"Etop\">[列印]</a>\n";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>\n";

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

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta21form.Lock = new Dictionary<string, string>(Lock);
        Brta211form.Lock = new Dictionary<string, string>(Lock);
        Brta212form.Lock = new Dictionary<string, string>(Lock);
    }

    private void QueryData() {
        Dictionary<string, string> step_data = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        step_data["rs_no"] = "";
        step_data["cs_rs_no"] = "";

        //案件主檔
        DataTable dtDmt = Sys.GetDmt(conn, seq, seq1);
        if (dtDmt.Rows.Count > 0) step_data["ectrlnum"] = dtDmt.Rows[0].SafeRead("ectrlnum", "0");

        if (submitTask == "A") {
            step_data["seq1"] = "_";
            step_data["step_date"] = DateTime.Today.ToString("yyyy/M/d");
            switch (DateTime.Today.DayOfWeek) {
                case DayOfWeek.Saturday: step_data["mp_date"] = DateTime.Today.AddDays(-1).ToShortDateString(); break;//星期六減一天
                case DayOfWeek.Sunday: step_data["mp_date"] = DateTime.Today.AddDays(-2).ToShortDateString(); break;//星期日減二天
                case DayOfWeek.Monday: step_data["mp_date"] = DateTime.Today.AddDays(-3).ToShortDateString(); break;//星期一減三天
                default: step_data["mp_date"] = DateTime.Today.AddDays(-1).ToShortDateString(); break;//減一天
            }
            step_data["send_cl"] = "1";
            step_data["rs_type"] = Sys.getRsType();
        }

        if ((submitTask == "U" || submitTask == "Q" || submitTask == "D") || (submitTask == "A" && prgid == "brta21")) {
            SQL = "Select * From vstep_dmt Where RS_No = '" + Request["rs_no"] + "'";
            DataTable dtStepMgt = new DataTable();
            conn.DataTable(SQL, dtStepMgt);

            if (dtStepMgt.Rows.Count > 0) {
                DataRow dr = dtStepMgt.Rows[0];

                step_data["rs_no"] = dr.SafeRead("rs_no", "");
                step_data["branch"] = dr.SafeRead("branch", "");
                step_data["seq"] = dr.SafeRead("seq", "");
                step_data["seq1"] = dr.SafeRead("seq1", "");
                step_data["fseq"] = Sys.formatSeq(step_data["seq"], step_data["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
                step_data["step_grade"] = dr.SafeRead("step_grade", "");
                step_data["nstep_grade"] = dr.SafeRead("step_grade", "");
                step_data["cgrs"] = dr.SafeRead("cg", "") + dr.SafeRead("rs", "");
                step_data["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                step_data["mp_date"] = dr.GetDateTimeString("mp_date", "yyyy/M/d");
                step_data["send_cl"] = dr.SafeRead("send_cl", "");
                step_data["receive_no"] = dr.SafeRead("receive_no", "");
                step_data["receive_way"] = dr.SafeRead("receive_way", "");
                step_data["rs_type"] = Sys.getRsType();
                step_data["rs_class"] = dr.SafeRead("rs_class", "");
                step_data["rs_code"] = dr.SafeRead("rs_code", "");
                step_data["act_code"] = dr.SafeRead("act_code", "");
                step_data["oact_code"] = dr.SafeRead("act_code", "");

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
                SQL += "and cg = 'G' and rs = 'R'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        step_data["ocase_stat"] = dr0.SafeRead("case_stat", "");
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
                step_data["pr_scode"] = dr.SafeRead("pr_scode", "");
                step_data["pr_scan"] = dr.SafeRead("pr_scan", "");
                step_data["pr_scan_page"] = dr.SafeRead("pr_scan_page", "");
                step_data["pr_scan_remark"] = dr.SafeRead("pr_scan_remark", "");
                step_data["pr_scan_path"] = dr.SafeRead("pr_scan_path", "");
                step_data["csd_flag"] = dr.SafeRead("csd_flag", "");
                step_data["cs_remark"] = dr.SafeRead("cs_remark", "");
                step_data["pmail_date"] = dr.GetDateTimeString("pmail_date", "yyyy/M/d");
                //step_data["cust_prod"] = dr.SafeRead("cust_prod", "");

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
            }
        }

        step_data["pdfsource"] = "GR";
        //2019/6/18修改，電子公文receive_way=R9其source=EGR，其餘皆為GR，路徑只有電子公文會不同須判斷，其餘都直接連到總管處顯示
        if (step_data["receive_way"] == "R9") {//R9_電子公文
            step_data["pdfsource"] = "EGR";
        }

        //2019/6/20因官收作業進入無案件編號  
        DataTable dtMGAttach = new DataTable();
        SQL = "select attach_path,attach_name,source,''view_path from dmt_attach where seq=" + step_data["seq"] + " and seq1='" + step_data["seq1"] + "' and step_grade=" + step_data["nstep_grade"] + " and source='" + step_data["pdfsource"] + "' and attach_flag<>'D' order by attach_sqlno ";
        conn.DataTable(SQL, dtMGAttach);
        for (int i = 0; i < dtMGAttach.Rows.Count; i++) {
            DataRow dr = dtMGAttach.Rows[i];
            string attach_path = Sys.Path2Nbtbrt(dr.SafeRead("attach_path", ""));
            string viewserver = "http://" + Sys.Host;

            //若區所主機找不到就找總所主機
            if (Sys.CheckFile(attach_path) == false) {
                viewserver = "http://" + Sys.MG_IIS;
                if (step_data["pdfsource"] == "EGR") {
                    attach_path = Sys.Path2MG(attach_path);
                }
            }
            dr["attach_path"] = attach_path;
            dr["view_path"] = viewserver + attach_path;
        }

        //管制資料
        DataTable dtCtrl = new DataTable();
        if (prgid == "brta21" && step_data.TryGet("from_flag") == "C") {//官收電子收文
            SQL = " select tctrl_sqlno as sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade ";
            SQL += " from ctrl_mgt_temp where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and ctrl_type like 'A%' ";
            SQL += " union select null as sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,mg_resp_step_grade as resp_grade ";
            SQL += " from resp_mgt_temp where temp_rs_sqlno=" + Request["temp_rs_sqlno"] + " and ctrl_type like 'A%' ";
        } else {
            SQL = " select sqlno,ctrl_type,ctrl_remark,ctrl_date,null as resp_date,null as resp_grade from ctrl_dmt ";
            SQL += " where rs_no='" + step_data["rs_no"] + "'";
            SQL += " union select sqlno,ctrl_type,ctrl_remark,ctrl_date,resp_date,resp_grade from resp_dmt ";
            SQL += " where rs_no='" + step_data["rs_no"] + "'";
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
        Response.Write(",\"step_data\":" + JsonConvert.SerializeObject(step_data, settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write(",\"ctrl_data\":" + JsonConvert.SerializeObject(dtCtrl, settings).ToUnicode() + "\n");//管制資料
        Response.Write(",\"mg_attach\":" + JsonConvert.SerializeObject(dtMGAttach, settings).ToUnicode() + "\n");//總管處官收電子公文檔
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
		<img src="<%=Page.ResolveUrl("~/images/icon1.gif")%>" style="cursor:pointer" align="absmiddle" title="期限管制" WIDTH="20" HEIGHT="20" onclick="dmt_IMG_Click(1)">&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon2.gif")%>" style="cursor:pointer" align="absmiddle" title="收發進度" WIDTH="25" HEIGHT="20" onclick="dmt_IMG_Click(2)">&nbsp;
		<img src="<%=Page.ResolveUrl("~/images/icon4.gif")%>" style="cursor:pointer" align="absmiddle" title="交辦內容" WIDTH="18" HEIGHT="18" onclick="dmt_IMG_Click(4)">&nbsp;
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
    <INPUT TYPE="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id=ctrl_flg name=ctrl_flg value="N"><!--判斷有無預設期限管制 N:無,Y:有-->
    <INPUT TYPE="hidden" id=havectrl name=havectrl value="N"><!--判斷有預設期限管制，需至少輸入一筆資料 N:無,Y:有-->
    <INPUT TYPE="hidden" id=oact_code name=oact_code>
    <INPUT TYPE="hidden" id=csmail_flag name=csmail_flag value="N">
    <center>
        <uc1:Brta21form runat="server" id="Brta21form" /><!--案件主檔欄位畫面，與收文共同-->
        <uc1:brta211form runat="server" id="Brta211form" /><!--官收欄位畫面-->
        <uc1:Brta212form runat="server" id="Brta212form" /><!--管制欄位畫面，與收文共同-->
     </center>

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
        settab("#grconf");

        //取得收文資料
        $.ajax({
            type: "get",
            url: "brta21_edit.aspx?json=Y&<%#Request.QueryString%>",
            //url: getRootPath() + "/ajax/_case_dmt.aspx?<%=Request.QueryString%>",
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
        brta21form.init();
        brta211form.init();
        brta212form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定

        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        $("#oact_code").val(jMain.step_data.oact_code);
        $("#span_fseq").html(jMain.step_data.fseq);

        brta21form.bind(jMain.step_data);//主檔資料
        brta211form.bind(jMain.step_data,jMain.mg_attach);//收文資料
        brta212form.bind(jMain.step_data,jMain.ctrl_data);//管制資料

        if(main.submittask!="A"){
            $("#span_rs_no").html("收文序號："+jMain.step_data.rs_no).show();
        }

        if(main.submittask=="U"||main.submittask=="Q"||main.submittask=="D"){
            if($("#cgrs").val()=="GR"){
                $("#tr_csmail_date").show();
            }
        }
    }

    //存檔
    function formAddSubmit(){
        if(main.submittask=="A"||main.submittask=="U"){
            if($("#keyseq").val()=="N"){
                alert("本所編號變動過，請按[確定]按鈕，重新抓取資料!!!");
                return false;
            }

            if(chkNull("本所編號",$("#seq"))) return false;
            if(chkNull("本所編號副碼",$("#seq1"))) return false;
            if(chkNull("收文日期",$("#step_date"))) return false;
            if(chkNull("來文單位",$("#send_cl"))) return false;
            if(chkNull("案性代碼",$("#rs_code"))) return false;
            if(chkNull("處理事項",$("#act_code"))) return false;

            if($("input[name='csflg']:checked").length==0){
                alert("客戶報導必須點選!!!");
                return false;
            }

            if($("input[name='csflg']:checked").val()=="Y"){//客戶報導
                if(chkNull("發文方式",$("#send_way"))) return false;
                if($("#oact_code").val()!=$("#act_code").val()){
                    if($("#mail_date").val()!=""){
                        var ans=confirm("原客戶函已寄出，修改後客戶函是否要重新寄發，若要重新寄發請按是，不要請按否！");
                        if(ans==true){
                            $("#csmail_flag").val("Y");
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

            //管制，有管制期限，至少需輸入一筆
            if ($("#ctrl_flg").val()=="Y"){
                $("#havectrl").val("N");
                for (var n = 1; n <= CInt($("#ctrlnum").val()) ;n++) {
                    var ctrl_type= $("#ctrl_type_" + n).val();
                    var ctrl_date= $("#ctrl_date_" + n).val();
                    if(ctrl_type!=""&&ctrl_date!=""){
                        $("#havectrl").val("Y");
                        break;
                    }
                }
                if ($("#havectrl").val()=="N"){
                    var answer="此進度代碼有管制期限確定不輸入嗎???";
                    if(!confirm(answer)){
                        return false;
                    }
                }
            }

            //註冊費繳納期數與發文案性關聯性檢查
            switch ($("#act_code").val()) {
                case "F1":
                    if ($("#pay_times").val() != "1") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第一期 』?");
                        if (ans != true) {
                            $("#act_code").focus();
                            return false;
                        } else {
                            $("#pay_times").val("1");
                            $("#hpay_times").val("1");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
                case "F2":
                    if ($("#pay_times").val() != "2") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                        if (ans != true) {
                            $("#act_code").focus();
                            return false;
                        } else {
                            $("#pay_times").val("2");
                            $("#hpay_times").val("2");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
                case "F0":
                    if ($("#pay_times").val() != "A") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 全期 』?");
                        if (ans != true) {
                            $("#act_code").focus();
                            return false;
                        } else {
                            $("#pay_times").val("A");
                            $("#hpay_times").val("A");
                            $("#pay_date").val($("#step_date").val());
                        }
                    }
                    break;
            }
        }
        postForm("Brta21_Update.aspx");
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

            postForm("Brta21_Update.aspx");
        }
    }

    //刪除
    function formDelSubmit(){
        if(confirm("是否確定刪除!!!")){
            $("#submittask").val("D");
            postForm("Brta21_Update.aspx");
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
</script>

