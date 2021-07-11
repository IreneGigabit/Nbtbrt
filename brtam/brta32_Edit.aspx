<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/brta32form.ascx" TagPrefix="uc1" TagName="brta32form" %>
<%@ Register Src="~/commonForm/Brta321form.ascx" TagPrefix="uc1" TagName="Brta321form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案客戶發文作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta32";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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
    protected object objResult = null;

    protected string submitTask = "";
    protected string json = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string case_no = "";
    protected string source = "";
  
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
        if (submitTask == "") submitTask = "A";
        json = (Request["json"] ?? "").Trim().ToUpper();
        seq = ReqVal.TryGet("seq", ReqVal.TryGet("aseq"));
        seq1 = ReqVal.TryGet("seq1", ReqVal.TryGet("aseq1"));
        case_no = ReqVal.TryGet("case_no");

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
        if (submitTask == "A") HTProgCap += "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap += "-<font color=blue>修改</font>";
        if (submitTask == "Q") HTProgCap += "-<font color=blue>查詢</font>";
        if (submitTask == "D") HTProgCap += "-<font color=blue>刪除</font>";

        if (submitTask == "Q" || submitTask == "D") {
            Lock["QLock"] = "Lock";
            Lock["Qdisabled"] = "Lock";
        }

        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>";
        StrFormBtnTop += "<a href=\"brta5m.aspx?prgid=brta5m&cgrs=cs\" target=\"Etop\">[列印]</a>";
        StrFormBtnTop += "<font style=\"cursor: pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"Help_Click()\">[說明]</font>";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
            if (((HTProgRight & 4) > 0 && submitTask == "A") || ((HTProgRight & 8) > 0 && submitTask == "U") || ((HTProgRight & 64) > 0 && submitTask == "U")) {
                StrFormBtn += "<input type=button id='button1' value='存　檔' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
            }
            if (((HTProgRight & 16) > 0 && submitTask == "D")) {
                StrFormBtn += "<input type=button id='button1' value='刪　除' class='cbutton bsubmit' onclick='formDelSubmit()'>\n";
            }
            StrFormBtn += "<input type=button value='重　填' class='cbutton' onclick='this_init()'>\n";
        }
    }

    //將共用參數傳給子控制項
    private void ChildBind() {
        Brta32form.Lock = new Dictionary<string, string>(Lock);
        Brta321form.Lock = new Dictionary<string, string>(Lock);
    }

    private void QueryData() {
        Dictionary<string, string> add_cs = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        //案件主檔
        DataTable dtDmt = Sys.GetDmt(conn, seq, seq1);
        if (dtDmt.Rows.Count > 0) add_cs["ectrlnum"] = dtDmt.Rows[0].SafeRead("ectrlnum", "0");

        add_cs["cgrs"] = Request["cgrs"];
        if (submitTask == "A") {
            add_cs["rs_no"] = "";
            add_cs["seq"] = "";
            add_cs["seq1"] = "_";
            add_cs["fseq"] = Sys.formatSeq(add_cs["seq"], add_cs["seq1"], "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            add_cs["step_date"] = DateTime.Today.ToShortDateString();
            add_cs["fees"] = "0";
            add_cs["fees_stat"] = "N";
            add_cs["rs_type"] = Sys.getRsType();
        }

        if (submitTask == "U" || submitTask == "Q" || submitTask == "D") {
            SQL = "SELECT * from vcs_dmt where rs_no='" + Request["rs_no"] + "'";
            DataTable dtCSDmt = new DataTable();
            conn.DataTable(SQL, dtCSDmt);
            if (dtCSDmt.Rows.Count > 0) {
                DataRow dr = dtCSDmt.Rows[0];
                add_cs["rs_no"] = dr.SafeRead("rs_no", "");
                add_cs["branch"] = dr.SafeRead("branch", "");
                add_cs["seq"] = dr.SafeRead("seq", "");
                add_cs["seq1"] = dr.SafeRead("seq1", "");
                add_cs["step_date"] = dr.GetDateTimeString("step_date", "yyyy/M/d");
                add_cs["send_way"] = dr.SafeRead("send_way", "");
                add_cs["rs_type"] = Sys.getRsType();
                add_cs["rs_class"] = dr.SafeRead("rs_class", "");
                add_cs["rs_code"] = dr.SafeRead("rs_code", "");
                add_cs["act_code"] = dr.SafeRead("act_code", "");
                add_cs["rs_detail"] = dr.SafeRead("rs_detail", "");
                add_cs["last_date"] = dr.GetDateTimeString("last_date", "yyyy/M/d");

                //取得案件狀態
                SQL = " select rs_type,rs_class,rs_code,act_code,case_stat,case_stat_name ";
                SQL += "from vcode_act ";
                SQL += "where rs_code = '" + add_cs["rs_code"] + "' ";
                SQL += "and act_code = '" + add_cs["act_code"] + "' ";
                SQL += "and rs_type = '" + add_cs["rs_type"] + "'";
                SQL += "and cg = '" + add_cs["cgrs"].Left(1) + "' ";
                SQL += "and rs = '" + add_cs["cgrs"].Right(1) + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        add_cs["ncase_stat"] = dr0.SafeRead("case_stat", "");
                        add_cs["ncase_statnm"] = dr0.SafeRead("case_stat_name", "");
                    }
                }
            }
        }

        //客發明細檔
        SQL = "SELECT * from csd_dmt where rs_no='" + add_cs["rs_no"] + "'";
        DataTable dtCSDDmt = new DataTable();
        conn.DataTable(SQL, dtCSDDmt);
        
        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        Response.Write("{");
        Response.Write("\"request\":" + JsonConvert.SerializeObject(ReqVal, settings).ToUnicode() + "\n");
        Response.Write(",\"add_cs\":" + JsonConvert.SerializeObject(add_cs, settings).ToUnicode() + "\n");//交辦本發預設值
        Response.Write(",\"csd_dmt\":" + JsonConvert.SerializeObject(dtCSDDmt, settings).ToUnicode() + "\n");//客發明細檔
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
    main.cgrs = "<%#ReqVal.TryGet("cgrs")%>";
    jMain={};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
		    <span id="span_rs_no" style="display:none">發文序號：</span>
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
    <INPUT TYPE="hidden" id="prgid1" name="prgid1" value="<%=Request["prgid1"]%>">
    <INPUT TYPE="hidden" id="submittask" name=submittask value="<%=submitTask%>">
    <INPUT TYPE="hidden" id="menu" name="menu" value="<%=Request["menu"]%>">

    <uc1:brta32form runat="server" ID="Brta32form" /><!--案件主檔欄位畫面-->
    <uc1:Brta321form runat="server" ID="Brta321form" /><!--客發欄位畫面-->
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
<div id="msg" style='text-align:left;height:100px'></div>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if(main.submittask=="A"){
                window.parent.tt.rows = "0%,100%";
            }
            if(main.submittask=="U"||main.submittask=="Q"||main.submittask=="D"){
                window.parent.tt.rows = "*,70%";
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
        //取得交辦資料
        $.ajax({
            type: "get",
            url: "brta32_edit.aspx?json=Y&<%#Request.QueryString%>",
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
        brta32form.init();
        brta321form.init();
        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        $(".Lock").lock();
        $(".Hide").hide();
    }
    
    main.bind = function () {
        if(main.submittask!="A"){
            $("#span_rs_no").html("發文序號："+jMain.add_cs.rs_no).show();
        }

        brta32form.bind(jMain.csd_dmt);//主檔資料
        brta321form.bind(jMain.add_cs);//發文資料
    }

    function Help_Click(){
        window.open(getRootPath() + "/brtam/國內案發收文系統操作手冊.htm","","width=700, height=500, top=50, left=50, toolbar=no, menubar=no, location=no, directories=no, resizeable=no, status=no, scrollbars=yes");
    }

    //存檔
    function formAddSubmit(){
        if($("#submittask").val()=="A"||$("#submittask").val()=="U"){
            for (var n = 1; n <= CInt($("#seqnum").val()) ;n++) {
                if(chkNull("本所編號",$("#seq_"+n))) return false;
                if(chkNull("本所編號副碼",$("#aseq1_"+n))) return false;
            }
            if(chkNull("發文日期",$("#step_date"))) return false;
            if(chkNull("案性代碼",$("#rs_code"))) return false;
            if(chkNull("處理事項",$("#act_code"))) return false;

            if($('#last_date').value!=""){
                var last_date = CDate($('#last_date').val());
                if(last_date.getTime()< Today().getTime()){
                    alert("法定期限須大於今天!!!");
                    return false;
                }
            }

            postForm(getRootPath() + "/brtam/Brta32_Update.aspx");
        }
    }

    function formDelSubmit(){
        var ans = confirm("是否確定刪除!!!");
        if (ans == true){
            $("#submittask").val("D");
            postForm(getRootPath() + "/brtam/Brta32_Update.aspx");
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
</script>

