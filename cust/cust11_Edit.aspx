<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust11Form.ascx" TagPrefix="uc1" TagName="cust11Form" %>
<%@ Register Src="~/cust/impForm/cust12Form.ascx" TagPrefix="uc1" TagName="cust12Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "專利客戶資料";//功能名稱
    protected string HTProgPrefix = "cust11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string SQL = "";
    protected string submitTask = "";
    protected string json = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string dept = "";
    protected string cust_att = "";
    protected string ctrl_open = "";

    //protected string connbr = "";

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
        
        //conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + ", ");
        //}

        cust_att = Request["cust_att"];
        cust_area = Request["cust_area"];
        cust_seq = Request["cust_seq"];
        submitTask = ReqVal.TryGet("submitTask").ToUpper();
        dept = Sys.GetSession("dept");
        ctrl_open = Request["ctrl_open"];
        //connbr = Request["databr_branch"] ?? "";
        //Sys.showLog("cust_area = " + cust_area + " , cust_seq = " + cust_seq);
        
        if (cust_att == "A") { HTProgCap = "專利聯絡人"; }
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";

        if ((HttpContext.Current.Request["prgid"] ?? "") == "")
        {
            HTProgCode = "cust11"; prgid = "cust11";
        }
        
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;

        if (HTProgRight >= 0) {
            PageLayout();
            //QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {

        if ((HTProgRight & 2) > 0)
        {
            if (submitTask == "U")
            {
                //StrFormBtnTop += "<a href=\"javascript:window.history.back();\" >[回清單]</a>\n";
            }
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }

        StrFormBtnTop += "<a href=cust11_add_help.aspx target=_blank>[輔助說明]</a>";

        if (((HTProgRight & 4) > 0 && (submitTask == "A")) || ((HTProgRight & 8) > 0 && (submitTask == "U")) ||
            ((HTProgRight & 8) > 0 && (submitTask == "A" || submitTask == "U" || submitTask == "C")) || (HTProgRight & 256) > 0)
        {
            if (submitTask == "Q") { }
            else
            {
                StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton bsubmit\"  />";//****class增加bsubmit.存檔時會控制鎖定.防止連點
                StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";
            }
        }
    }


    //private void QueryData() {
    //    Dictionary<string, string> add_gr = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    //    SQL = "select a.*,c.branch,c.cappl_name as appl_name,c.csd_flag as scsd_flag,c.cs_remark,c.pmail_date";
    //    SQL += ",c.step_date,c.mp_date,c.rs_detail,c.rs_no,c.cg,c.rs,c.send_cl,c.rs_class,c.rs_code,c.act_code";
    //    SQL += ",c.doc_detail,c.mg_rs_sqlno,c.receive_no,c.receive_way,c.pr_scode,c.pr_scan,c.pr_scan_page,c.pr_scan_remark,c.pr_scan_path";
    //    SQL += ",(select sc_name from sysctrl.dbo.scode where scode=c.dmt_scode) as sc_name,c.cust_prod";
    //    SQL += ",''fseq,''nstep_grade,''cs_detail,''send_way,''print_date,''mail_date";
    //    SQL += " from grconf_dmt a ";
    //    SQL += " inner join vstep_dmt c on a.seq=c.seq and a.seq1=c.seq1 and a.step_grade=c.step_grade and a.rs_sqlno=c.rs_sqlno ";
    //    //SQL += " where a.seq=" + seq + " and a.seq1='" + seq1 + "' and a.step_grade=" + step_grade;
    //    //DataTable dtGrConfDmt = new DataTable();
    //    //conn.DataTable(SQL, dtGrConfDmt);
    //    Response.End();
    //}
</script>


<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <meta http-equiv="x-ua-compatible" content="IE=10">
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【cust11_Edit <%=HTProgCap%>】
            &nbsp;&nbsp;<span id="span_rs_no"></span>
            <span id="span_scodenm"></span>
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
<INPUT TYPE="hidden" id="submitTask" name=submitTask value="<%=submitTask%>">
<input type="hidden" id="dept" name="dept" value="<%=dept%>" />
<INPUT TYPE="hidden" name=databr_branch id="databr_branch" value="<%=Request["databr_branch"]%>">
<INPUT TYPE="hidden" name=old_branch id="old_branch" value="<%=Request["old_branch"]%>"> <!--查詢條件-->
<INPUT TYPE="hidden" name=old_cust_area id="old_cust_area" value="<%=Request["old_cust_area"]%>">
<INPUT TYPE="hidden" name=old_cust_seq id="old_cust_seq" value="<%=Request["old_cust_seq"]%>">
<INPUT TYPE="hidden" name=tran_flag id="tran_flag" value="<%=Request["tran_flag"]%>">
<INPUT TYPE="hidden" name=brtran_sqlno value="<%=Request["brtran_sqlno"]%>">
<INPUT TYPE="hidden" name=tran_cust_area value="<%=Request["tran_cust_area"]%>">
<INPUT TYPE="hidden" name=tran_cust_seq value="<%=Request["tran_cust_seq"]%>">
   <%-- <INPUT TYPE="hidden" id="cust_area" name="cust_area" value="<%=cust_area%>">
    <INPUT TYPE="text" id="cust_seq" name="cust_seq" value="<%=cust_seq%>">--%>

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab" >
                <td class="tab" href="#custz" style="font-size:15pt;">客戶資料</td>
                <td class="tab" href="#custz_att" style="font-size:15pt;"><%#(submitTask == "A")? "聯絡人新增":"聯絡人資料" %></td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#custz">
                <uc1:cust11Form runat="server" ID="cust11Form" />
            </div>
            <div class="tabCont" id="#custz_att">
                <uc1:cust12Form runat="server" ID="cust12Form" />
            </div>  
       </td>
    </tr>
    </table>

    <div id="div_sign" style="display:none">
        <br>
        <table id="tabhd1" border="0" width="70%" cellspacing="1" cellpadding="0" align="center" style="font-size: 9pt">
	        <TR>
		        <td width="14%"><input type=radio name="usesign" id="usesign1" onclick="toselect()" checked><strong>正常簽核:</strong></td>
		        <td><strong>上級主管:</strong><input type=hidden name=Msign id=Msign value=""></td>
		        <td style="display:none"><strong>管制日期:</strong>
		            <input type=text name="signdate" id="signdate" size=10 readonly class="dateField">
		        </td>
	        </TR>
	        <TR>
		        <td ><input type=radio name="usesign" id="usesign2"><strong>特殊處理:</strong></td>
		        <td ><input type=radio name=Osign onclick="$('#usesign2').prop('checked',true)" >
			        <select name=selectsign id=selectsign>
				        <option value="" style="color:blue">請選擇主管</option>
			        </select>
		        </td>
		        <td style="display:none">
                    <input type=radio name=Osign disabled onclick="$('#usesign2').prop('checked',true)">
		            <input type=text name=Nsign id=Nsign size=10 readonly>(薪號)
		        </td>
	        </TR>
        </table>
        <input type=hidden id="GrpID" name="GrpID" value="">
        <input type=hidden id=signid name=signid>
    </div>
            <%#DebugStr%>

</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
</table>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrSaveBtn%>
            <%#StrResetBtn%>                    
        </td>
    </tr>
</table>

        <div id="dialog"></div>

</body>
</html>

<script type="text/javascript">

    $(function () {
        if (window.parent.tt !== undefined) {
            //window.parent.tt.rows = "100%,0%";
            this_init();
        }
        else {
            //cust11_Edit的詳細功能用
            //loadData();
            //loadAttData();
            //if (CInt($("#hatt_sql").val()) < 1 ) {
            //    $("#noData").show();
            //} 
            //cust12form.LockAll();
            //if ($("#submitTask").val() == "Q")
            //{
            //    cust11form.LockAll();
            //}
            //settab("#custz");
            this_init();

        }
    });

    function this_init() {

        if (window.parent.tt == undefined) {
    
        }
        else {
            if ('<%=ctrl_open%>' == "Y") {
                //cust45_List 客戶/申請人綜合查詢清單用
                window.parent.tt.rows = "40%, 60%";
            }
            else {
                window.parent.tt.rows = "0%, 100%";
            }
        }

        if($("#submitTask").val() != "A")
        {
            loadData();
            //cust12Form控制
            loadAttData();
            if (CInt($("#hatt_sql").val()) < 1 ) {
                $("#noData").show();
            } 

            cust12form.LockAll();

            if ($("#submitTask").val() == "Q")
            {
                cust11form.LockAll();
            }
            else
            {
                var d = <%="'"+dept+"'"%>;
                for (var i = 1; i <= CInt($("#hatt_sql").val()); i++) {
                    if ($("#dept_"+i).val() == d) {
                        $("#btnattedit_"+i).show();
                        $("#btnattedit_"+i).attr("onclick", "cust12form.GoToEditAtt("+<%=cust_seq%> +","+i+");")
                    }
                }
            }
                
        }
        else
        {//如果是新增
            if ($("#databr_branch").val() != "" && $("#tran_flag").val() == "B")//brta78確認轉案作業
            {
                loadData();
                loadAttData();
                for (var i = 1; i <= CInt($("#hatt_sql").val()); i++) {
                    if ($("#dept_"+i).val() == d) {
                        $("#btnattedit_"+i).show();
                        $("#btnattedit_"+i).attr("onclick", "cust12form.GoToEditAtt("+$("#old_cust_seq").val() +","+i+");")
                    }
                }
                $("#cust_area_str, #cust_seq_str").text('');
                $("#cust_area").val('<%=Sys.GetSession("seBranch")%>');
                $("#<%=dept.ToLower()%>scode").val('<%=Request["scode1"]%>');
                $("#<%=dept.ToLower()%>scode").lock();
                $("#span_scodenm").text('營洽：<%=Request["scode1"]%>-<%=Request["scode1nm"]%>');
            }
            else {

                addDefaultValue();
                if (CInt($("#hatt_sql").val()) < 1)
                {
                    cust12form.addAtt();
                }
                var DeptStr = <%= "'" + Sys.GetSession("dept") + "'"%>;
                cust12form.addReadOnly($("#submitTask").val(), DeptStr);

                var a = <%="'"+cust_att+"'"%>;
                if (a == "A") {
                    loadData();
                    cust11form.LockAll();
                }
            }
        }
        //cust12Form控制
        SetReadOnly();
        
        var SwitchType = <%="'" + ReqVal.TryGet("Type") + "'"%>;
        if (SwitchType == "ap_nameaddr") {//新增聯絡人資料
            settab("#custz_att");
            
        }
        else {//客戶資料
            settab("#custz");
        }

        $("input.dateField").datepick();
        cust11form.ppaytypeChange();

    }//init() End



    // 切換頁籤
    $("#CTab td.tab").click(function (e) {
        settab($(this).attr('href'));

        //hide Save
        var a = <%="'"+cust_att+"'"%>;
        if (a == "A")//Add custz_att
        {
            if ($(this).attr('href') == "#custz_att") {
                $("#btnSave").show();
                $("#btnReset").show();
            }
            else {
                $("#btnSave").hide();
                $("#btnReset").hide();
            }
        }
        else//Add custz
        {
            var s = <%="'" + submitTask + "'"%>;
            if (s != "A") {
                if ($(this).attr('href') == "#custz") {
                    $("#btnSave").show();
                    $("#btnReset").show();
                }
                else {
                    $("#btnSave").hide();
                    $("#btnReset").hide();
                }
            }
        }


        
    });
    function settab(k) {

        $("#CTab td.tab").removeClass("seltab").addClass("notab");
        $("#CTab td.tab[href='" + k + "']").addClass("seltab").removeClass("notab");
        $("div.tabCont").hide();
        $("div.tabCont[id='" + k + "']").show();
    }
    // 切換頁籤

    function loadAttData() {
        var con = '<%=cust_area%>';
        if (NulltoEmpty(con) == "") {
            if ($("#databr_branch").val() != "") {
                con = $("#databr_branch").val();
            }
            else {
                con = '<%=Sys.GetSession("seBranch")%>';
            }
        }

        var psql = "";
        if ($("#databr_branch").val() != "" && $("#tran_flag").val() == "B" && '<%=cust_area%>' == "" && '<%=cust_seq%>' == "") {
            psql = "select * from custz_att where cust_area = '" + $("#old_cust_area").val() + "' and cust_seq = '" + $("#old_cust_seq").val() + "' order by att_sql";
        }
        else {
            psql = "select * from custz_att where cust_area = '<%=cust_area%>' and cust_seq = '<%=cust_seq%>' order by att_sql";
        }

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql + "&connbr=" + con,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                cust12form.bind(JSONdata);

            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }



    function loadData() {

        var con = '<%=cust_area%>';
        if (NulltoEmpty(con) == "") {
            if ($("#databr_branch").val() != "") {
                con = $("#databr_branch").val();
            }
            else {
                con = '<%=Sys.GetSession("seBranch")%>';
            }
        }

        var psql = "";
        if ($("#databr_branch").val() != "" && $("#tran_flag").val() == "B" && '<%=cust_area%>' == "" && '<%=cust_seq%>' == "") {
            psql = "select * FROM custz a left join apcust b ON a.cust_seq = b.cust_seq left join (select cust_seq, ap_cname1 as name1, ap_cname2 as name2 from apcust) as c  ON c.cust_seq = a.ref_seq "+
                           "where a.cust_area = '" + $("#old_cust_area").val() + "' and a.cust_seq = '" + $("#old_cust_seq").val() + "'";
        }
        else {
            psql = "select * FROM custz a left join apcust b ON a.cust_seq = b.cust_seq left join (select cust_seq, ap_cname1 as name1, ap_cname2 as name2 from apcust) as c  ON c.cust_seq = a.ref_seq "+
                           "where a.cust_area = '<%=cust_area%>' and a.cust_seq = '<%=cust_seq%>'";
        }

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql + "&connbr=" + con,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                if (JSONdata.length > 0) {
                    cust11form.bind(item);
                }
                else {
                    window.parent.tt.rows = "100%, 0%";//cust45list & cust46list用
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }

   

    function cust_attSave() {
        if ($("#attention_1").val() == "") {
            alert("聯絡人必須輸入!");
            $("#attention_1").focus();
            return;
        }

        if ($("#att_addr1_1").val() == "") {
            alert("聯絡地址必須輸入!");
            $("#att_addr1_1").focus();
            return;
        }

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust12_Update.aspx",formData)
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

    function custzSave() {

        if (cust11form.chkSaveAddData() == false) {
            return;
        }
        if ($("#attention_1").val() == "") {
            alert("聯絡人必須輸入!");
            settab("#custz_att");
            $("#attention_1").focus();
            return;
        }
        if ($("#att_addr1_1").val() == "") {
            alert("聯絡地址必須輸入!");
            settab("#custz_att");
            $("#att_addr1_1").focus();
            return; 
        }



            //****改用ajax,才不用處理update後導頁面
            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("cust11_Update.aspx",formData)
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
    }//custzSave



    $("#btnSave").click(function (e) {

        var SwitchType = <%="'" + ReqVal.TryGet("Type") + "'"%>;
        if (SwitchType == "ap_nameaddr")
        {//聯絡人資料
            cust_attSave();
        }
        else//客戶資料
        {
            custzSave();
        }
    });


    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
    });


    function addDefaultValue() {
        //common
        $("#ap_cname1").val(<%= "'" + ReqVal.TryGet("ap_cname1") + "'"%>);
        $("#ap_country").val("T");
        $("#apclass").val("AC");
        $("#tr_payout").hide();
        $("#tr_tdate").hide();
        $("#tr_pdate").hide();
        cust11form.apclassChange();
        //common

        var d = <%="'"+dept+"'"%>;
        if (d == "P") {
            $("#pdis_type").val("00");
            $("#ppay_type").val("00");
        }
        else {

            $("#tdis_type").val("00");
            $("#tpay_type").val("00");
        }
    
    }


    function SetReadOnly() {
        //分兩個Tab處理
        var a = <%="'"+cust_att+"'"%>;
        var d = <%="'"+dept+"'"%>;
       
        if (a == "A")
        {}
        else //cust11Form
        {
            var s = <%="'"+submitTask+"'"%>;
            if (s == "A")
            {//add
                if (d == "P")
                {
                    
                    $(".dept_t").hide();

                    for (var i = 1; i < 4; i++) {
                        $("#tr_T"+i).hide();
                    }
                    $("#tr_P3").hide();
                }
                else
                {
                    for (var i = 1; i < 4; i++) {
                        $("#tr_P"+i).hide();
                    }
                    $("#tr_T3").hide();
                }
            }
            else
            {//edit
                cust11form.EditLock();//common

                if (d == "P")
                {
                    cust11form.T_ColLock();
                    for (var i = 1; i < 4; i++) {
                        $("#tr_T"+i).lock();
                    }
                    $("#showpspay input[type=text]").each(function () {
                        $(this).lock();
                    })    
                    $("#tr_P3").lock();
                }
                else
                {
                    for (var i = 1; i < 4; i++) {
                        $("#tr_P"+i).lock();
                    }
                    $("#tr_T3").lock();
                }
            }
        }
    }//SetReadOnly

    function GoToSearch() {
        var s = <%="'"+submitTask+"'"%>;
        if (s == "A") {
            s = "U";
        }
        reg.action = "cust11_1.aspx?cust_area=<%=Sys.GetSession("seBranch")%>&submitTask="+s;
        reg.submit();
    
    }


</script>
