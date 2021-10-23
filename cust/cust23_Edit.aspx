<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust23TextForm.ascx" TagPrefix="uc1" TagName="cust23TextForm" %>
<%@ Register Src="~/cust/impForm/cust23AttachForm.ascx" TagPrefix="uc1" TagName="cust23AttachForm" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "客戶特殊備註管理";//功能名稱
    protected string HTProgPrefix = "cust23";//程式檔名前綴
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
    protected string syscode = "";
    protected string txt_dept = "";
    protected string cust_att = "";
    protected string ctrl_open = "";
    //備註種類
    protected string html_ReportType = Sys.getCustCode("cmark_report", "", "sortfld").Option("{cust_code}", "{code_name}", "attr1={mark}", false);
    protected string html_ReportFileType = Sys.getCustCode("cmark_attach", "", "sortfld").Radio("rpt_spe_mark1_##","{cust_code}","{code_name}");

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

        dept = Sys.GetSession("dept");
        if (dept == "P")
        {
            syscode = "BRP"; txt_dept = "|PI|PE|";
        }
        else if (dept == "T")
        {
            syscode = "BTBRT"; txt_dept = "|TI|TE|";
        }
        else
        {
            syscode = "ACC"; txt_dept = "|AC|";
        }
        
        cust_area = Sys.GetSession("seBranch");
        submitTask = ReqVal.TryGet("submitTask").ToUpper();
        
        if (submitTask == "A") cust_seq = "";
        else cust_seq = Request["cust_seq"]; 
        
        dept = Sys.GetSession("dept");
        ctrl_open = Request["ctrl_open"];
        //connbr = Request["databr_branch"] ?? "";
        //Sys.showLog("cust_area = " + cust_area + " , cust_seq = " + cust_seq);
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";

        
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


</script>
<style>
    input[type=checkbox] {
    vertical-align:middle;
    }
</style>

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
        <td class="text9" nowrap="nowrap">&nbsp;【cust23_Edit <%=HTProgCap%>】
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
   <%-- <INPUT TYPE="hidden" id="cust_area" name="cust_area" value="<%=cust_area%>">
    <INPUT TYPE="text" id="cust_seq" name="cust_seq" value="<%=cust_seq%>">--%>

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
            <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
			<TR>
				<TD class=lightbluetable align=right>客戶編號：</TD>
				<TD class=whitetablebg>
					<INPUT type="text" class="SEdit" readOnly="readonly" size="3" value="<%=cust_area%>" id="cust_area" name="cust_area">-
					<INPUT type="text" size="6" value="<%=cust_seq%>" id="cust_seq" name="cust_seq">
					<INPUT type="button" class="cbutton" style="display:none" value=確定 id="btncust">
					<INPUT type="hidden" id=apsqlno name=apsqlno>
					<INPUT type="hidden" id=apcust_no name=apcust_no>
					<INPUT type="hidden" id=now_cust_seq name=now_cust_seq>
				</TD>
				<TD class=lightbluetable align=right>專利營洽：</TD>
				<TD class=whitetablebg>
					<INPUT type="text" class=SEdit readOnly size=5 id=pscode name=pscode>-
					<INPUT type="text" class=SEdit readOnly size=10 id=pscodenm name=pscodenm>
				</TD>
			</TR>
			<TR>
				<TD class=lightbluetable align=right>客戶名稱：</TD>
				<TD class=whitetablebg>
					<INPUT class=SEdit readOnly size=47 id="ap_cname" name="ap_cname">
				</TD>
				<TD class=lightbluetable align=right>商標營洽：</TD>
				<TD class=whitetablebg>
					<INPUT type="text" class=SEdit readOnly size=5 id=tscode name=tscode>-
					<INPUT type="text" class=SEdit readOnly size=10 id=tscodenm name=tscodenm>
				</TD>
			</TR>
		    </table>
            </td>
    </tr>
    <tr>
        <td>
        <input type="hidden" id="hreport_sql" name="hreport_sql" value=""><!--筆數-->
		<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
			<TR class=whitetablebg>
				<TD class=lightbluetable1 style="color:#ffffff" align=center colspan=5>
					報　表　備　註
				</TD>
			</TR>
			<TR>
				<TD class=whitetablebg align=center>
					<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" id="reportlist">
					<TFOOT>
						<TR class=whitetablebg>
							<TD colspan=9>
								<INPUT type="button" id="AddReport_button" class=cbutton  value=增加備註項目 onclick="AddRptRemark()">
							</TD>
						</TR>
					</TFOOT>
					<THEAD>
						<TR>
							<TD class=lightbluetable align=center width=5%>刪除</TD>
							<TD class=lightbluetable align=center width=15%>系統單位</TD>
							<TD class=lightbluetable align=center width=10%>種類</TD>
							<TD class=lightbluetable align=center width=10%>聯絡人</TD>
							<TD class=lightbluetable align=center>選項</TD>
							<TD class=lightbluetable align=center width=10%>停用日期</TD>
							<TD class=lightbluetable align=center width=10%>最後異動</TD>
						</TR>
                        <script type="text/html" id="rpt_template"><!--設定樣板-->
						<TR class=sfont9  id="tr_rpt_##">
							<TD class=whitetablebg align=center>##.
								<input type="checkbox" id="rpt_del_##" name="rpt_del_##" value="Y">
								<INPUT type="hidden" size=1 id="rpt_upd_flag_##" name="rpt_upd_flag_##">
							</TD>
							<TD class=whitetablebg align=center>
								<input TYPE="radio" NAME="rpt_syscode_##" id="rpt_syscode_##_BRP" value="BRP"><label for="rpt_syscode_##_BRP">專利</label>
								<input TYPE="radio" NAME="rpt_syscode_##" id="rpt_syscode_##_BTBRT" value="BTBRT"><label for="rpt_syscode_##_BTBRT">商標</label>
								<input TYPE="radio" NAME="rpt_syscode_##" id="rpt_syscode_##_ACC" value="ACC"><label for="rpt_syscode_##_ACC">會計</label>
								<INPUT type="hidden" id=o_rpt_syscode_##>
							</TD>
							<td align=center>
								<select id="rpt_mark_type2_##" name="rpt_mark_type2_##" size="1">
                                    <%--onchange="javascript:lockRptAtt(this,'rpt_att_sql_##')--%>
                                    <%=html_ReportType%>
								</select>
								<INPUT type="hidden" id="o_rpt_mark_type2_##" name="o_rpt_mark_type2_##">
							</td>
							<TD class=whitetablebg align=center>
								<SELECT id="rpt_att_sql_##" name="rpt_att_sql_##" size=1>
								</SELECT>
								<INPUT type="hidden" id="o_rpt_att_sql_##" name="o_rpt_att_sql_##">
							</TD>
							<td>
                                <%=html_ReportFileType%>
								<INPUT type="hidden" id="o_rpt_spe_mark1_##" name="o_rpt_spe_mark1_##">
							</td>
							<td align=center>
                                <input type="text" name="rpt_end_date_##" id="rpt_end_date_##" size="10" readonly="readonly" class="dateField">
								<INPUT type="hidden" id="o_rpt_end_date_##" name="o_rpt_end_date_##">
							</td>
							<td align=center>
								<span id="rpt_tran_date_##"></span><BR>
								<span id="rpt_tran_scodenm_##"></span>
								<INPUT type="hidden" id="rpt_mark_sqlno_##" name="rpt_mark_sqlno_##">
							</td>
						</TR>
                        </script>
					</THEAD>
					<TBODY>
					</TBODY>
					</table>
				</td>
			</TR>
		</table>
        </td>
    </tr>
    <TR class=whitetablebg>
		<TD class=lightbluetable1 style="color:#ffffff" align=center colspan=4>
			說　明　備　註
		</TD>
	</TR>
    <tr>
        <td>
        <table border="0" cellspacing="1" cellpadding="0">
            <tr id="CTab" >
                <td class="tab" href="#mark_text">備註設定</td>
                <td class="tab" href="#mark_attach">相關檔案</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#mark_text">
                <uc1:cust23TextForm runat ="server" ID="cust23TextForm" />
            </div>
            <div class="tabCont" id="#mark_attach">
                <uc1:cust23AttachForm runat="server" ID="cust23AttachForm" />
            </div>  
       </td>
    </tr>
    </table>

    
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
<div>
※報表備註:<BR>
　－依系統單位控制對應各自的系統才可修改<BR>
　－「聯絡人」依種類做控制,若設為不可選擇(cust_code.mark='N'),則鎖定<BR>
<BR>
※說明備註:<BR>
　－「部門」依系統對應開放勾選,其餘鎖定<BR>
　－「相關檔案」僅上傳人員可維護<BR>
</div>
        <div id="dialog"></div>

</body>
</html>

<script type="text/javascript">

    var bTextFormData = true;
    var bAttachFormData = true;
    var bReportMarkFormData = true;

    var nReport=0;//報表備註設定計數
    $(function () {
        if (window.parent.tt !== undefined) {
            if ('<%=submitTask%>' == "U") {
                window.parent.tt.rows = "30%,70%";
            }
            else {
                window.parent.tt.rows = "0%,100%";
            }
        }

        if($("#submitTask").val() == "A") {
            $("#cust_seq").val('');
            settab("#mark_text");
            cust23textform.init();
        }
        else {
            loadData();
        }

    });

    function this_init() {
        settab("#mark_text");
	
        if ('<%=submitTask%>' == "U" && '<%=Request["apattach_sqlno"]%>' != "") {
            settab("#mark_attach");
        }
        //還原原始狀態
        $("#submitTask").val("<%=submitTask%>");
        $("#cust_seq").val("<%=cust_seq%>");
        $("#now_cust_seq").val("<%=cust_seq%>");
        $("#apsqlno").val("");
        $("#apcust_no").val("");
        $("#ap_cname").val("");
        $("#pscode").val("");
        $("#pscodenm").val("");
        $("#tscode").val("");
        $("#tscodenm").val("");
	    
        nReport = 0;
        $("#hreport_sql").val("0");
        $("#htext_sql").val("0");
        $("#hattach_sql").val("0");

        $("#reportlist>tbody tr").remove();
        $("#tabText>tbody tr").remove();
        $("#tabAttach>tbody tr").remove();
    }

    function loadData() {

        settab("#mark_text");

        cust23textform.init();
        loadCustData();
        loadReportMarkFormData();
        loadTextFormData();
        loadAttachFormData();


        if($("#submitTask").val() != "A")
        {
            $("#cust_seq").lock();
            
            if ($("#submitTask").val() == "Q") {
                SetReportmarkReadOnly();
                cust23textform.SetReadOnly();
                cust23attachform.SetReadOnly();
            }

            if ($("#submitTask").val() == "U") {
    
                if ('<%=Request["apattach_sqlno"]%>' != "") {
                    settab("#mark_attach");
                    $("#btnattach_1").lock();
                }
            }
        }
        else//如果是新增
        {
          
        }
    }



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
    // 切換頁籤

    //檢查有改過客編則要重新載入
    $("#cust_seq").on("blur",function(){
        if($("#now_cust_seq").val()!=$(this).val()){
            //$("#btncust").click();
            loadData();
            if (bTextFormData == true || bAttachFormData == true || bReportMarkFormData == true) {
                alert("此客戶已有設定備註,系統將載入目前設定!");
            }
        }
    })



    //新增一筆
    function AddRptRemark() {
        if ($.trim($("#cust_seq").val())==""){
            alert("請輸入客戶編號，才可新增 !!!");
            return false;
        }

        nReport++;
        $("#hreport_sql").val(nReport);
        //var strLine1 = "<tr class=sfont9 id='tr_rpt_"+nReport+"'>" + $("#reportlist>thead tr").eq(1).html().replace(/##/g, nReport) + "</tr>";
        var strLine1 = $("#rpt_template").text() || "";
        strLine1 = strLine1.replace(/##/g, nReport);

        
        $("#reportlist>tbody").append(strLine1);
	
        //預設單位部門可選項目
        $("input[name='rpt_syscode_"+nReport+"'][value='<%=syscode%>']").prop('checked', true).trigger("click");
        $("input[name='rpt_syscode_"+nReport+"'][value!='<%=syscode%>']").prop('disabled', true);
        //選項預設pdf
        $("input[name='rpt_spe_mark1_"+nReport+"'][value='pdf']").prop('checked', true).trigger("click");
        //種類預設通用
        $("#rpt_mark_type2_"+nReport).val('_');
        cust23textform.searchCustAtt(nReport, "rpt_att_sql_", '<%=dept%>');
        //getAtt("#rpt_att_sql_"+nReport,"<%=syscode%>");
        $("input.dateField").datepick();
    }

    //說明備註-備註設定
    function loadTextFormData() {
        var psql = "select convert(varchar,m.tran_date,120)trandate,convert(varchar,m.end_date,111)enddate, *,  ";
        psql += "(select sc_name from sysctrl.dbo.scode s where m.tran_scode=s.scode) tran_scodenm ";
        psql += "from apcust_mark m where mark_type='cmark_text' ";
        psql += "and cust_area ='" + $("#cust_area").val() + "' and cust_seq = '" + $("#cust_seq").val() + "'";

        if ($("#submitTask").val() == "U") {//編輯模式只顯示單筆
            psql += " and mark_sqlno='<%=Request["mark_sqlno"]%>'";
        }
        psql += " order by mark_sqlno";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    cust23textform.bind(JSONdata);
                    bTextFormData = true;
                }
                else {
                    bTextFormData = false;
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

    //說明備註-相關檔案
    function loadAttachFormData() {
        var psql = "select convert(varchar,t.in_date,111)indate, *, ";
        psql += "(select sc_name from sysctrl.dbo.scode s where t.in_scode=s.scode) in_scodenm ";
        psql += "from apcust_attach t where source='custz' ";
        psql += "and cust_area ='" + $("#cust_area").val() + "' and cust_seq = '" + $("#cust_seq").val() + "'";

        if ($("#submitTask").val() == "U") {//編輯模式只顯示單筆
            psql += " and apattach_sqlno='<%=Request["apattach_sqlno"]%>'";
        }
        psql += " order by apattach_sqlno";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length >0) {
                    cust23attachform.bind(JSONdata, '<%=HTProgRight%>');
                    bAttachFormData = true;
                }
                else {
                    bAttachFormData = false;
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

    //報表備註
    function loadReportMarkFormData() {
        var psql = "select convert(varchar,m.tran_date,120)trandate,convert(varchar,m.end_date,111)enddate, *,  ";
        psql += "(select sc_name from sysctrl.dbo.scode s where m.tran_scode=s.scode) tran_scodenm ";
        psql += "from apcust_mark m where mark_type='cmark_report' ";
        psql += "and cust_area ='" + $("#cust_area").val() + "' and cust_seq = '" + $("#cust_seq").val() + "'";
        
        if ($("#submitTask").val() == "U") {//編輯模式只顯示單筆
            psql += " and mark_sqlno='<%=Request["mark_sqlno"]%>'";
        }
        psql += " order by mark_sqlno";

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    $.each(JSONdata, function (i, item) {
                        AddRptRemark();//新增一行
                        //$row=$(this);
                        var rSyscode=item.syscode;
                        var rSpe_mark1=item.spe_mark1;
                        $("input[name='rpt_syscode_"+nReport+"'][value='"+rSyscode+"']").prop('checked', true).trigger("click");
                        if("<%=syscode%>"==rSyscode){
                            $("input[name='rpt_syscode_"+nReport+"'][value='"+rSyscode+"']").prop('disabled', false);
                        }else{
                            $("input[name='rpt_syscode_"+nReport+"']").prop('disabled', true);
                        }
                        $("#o_rpt_syscode_" + nReport).val(rSyscode);
                        //帶對應的聯絡人清單-清空重放
                        $("#rpt_att_sql_" + nReport).empty();
                        var d = "";
                        if (item.syscode == "BRP") {
                            d = "P"
                        } else if (item.syscode == "BTBRT") {
                            d = "T"
                        }
                        cust23textform.searchCustAtt(nReport, "rpt_att_sql_", d);

                        $("#rpt_mark_type2_"+nReport).val(item.mark_type2).trigger("change");
                        $("#o_rpt_mark_type2_"+nReport).val(item.mark_type2);
                        //getAtt("#rpt_att_sql_"+nReport,rSyscode);
                        $("#rpt_att_sql_"+nReport).val(item.att_sql);
                        $("#o_rpt_att_sql_"+nReport).val(item.att_sql);
                        $("input[name='rpt_spe_mark1_"+nReport+"'][value='"+rSpe_mark1+"']").prop('checked', true).trigger("click");
                        $("#o_rpt_spe_mark1_"+nReport).val(rSpe_mark1);
                        $("#rpt_end_date_"+nReport).val(dateReviver(item.end_date, "yyyy/M/d"));
                        $("#o_rpt_end_date_"+nReport).val(dateReviver(item.end_date, "yyyy/M/d"));
                        $("#rpt_tran_date_"+nReport).html(dateReviver(item.tran_date, "yyyy/M/d hh:mm:ss"));
                        $("#rpt_tran_scodenm_"+nReport).html(item.tran_scodenm);
                        $("#rpt_mark_sqlno_"+nReport).val(item.mark_sqlno);
                        <%--if(rSyscode!="<%=syscode%>")lockTr("rpt_",nReport);--%>
                        //新增模式要鎖定
                        if ("<%=submitTask%>" == "A") lockTr("rpt_", nReport);
                        //不同單位要鎖定
                        if (item.syscode != '<%=syscode%>') lockTr("rpt_", nReport);
                
                    })

                    bReportMarkFormData = true;
                }
                else {
                    bReportMarkFormData = false;
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

    function lockTr(prefix,rNo){
        $("#tr_"+prefix+rNo+" select,#tr_"+prefix+rNo+" img,#tr_"+prefix+rNo+" textarea").prop('disabled', true);
        $("#tr_"+prefix+rNo+" input").prop('disabled', true);
    }

    function loadCustData() {

        var psql = "SELECT apsqlno,ap.apcust_no,c.cust_area,c.cust_seq,ap_cname1,ap_cname2,pscode,tscode, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=c.pscode) as pscodenm, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=c.tscode) as tscodenm, ";
        psql += "(select count(*) from apcust_mark m where m.cust_area = c.cust_area AND m.cust_seq = c.cust_seq and m.mark_type in('cmark_report','cmark_text')) as remarkcount, ";
        psql += "(select count(*) from apcust_mark m where m.cust_area = c.cust_area AND m.cust_seq = c.cust_seq and m.mark_type in('cmark_mail')) as mailcount, ";
        psql += "(select count(*) from apcust_attach t where t.cust_area = c.cust_area AND t.cust_seq = c.cust_seq and t.source='custz') as attachcount ";
        psql += "FROM custz c ";
        psql += "INNER JOIN apcust ap ON c.cust_area = ap.cust_area AND c.cust_seq = ap.cust_seq ";
        psql += "where 1=1 and c.cust_area = '" + $("#cust_area").val() + "' and c.cust_seq = '" + $("#cust_seq").val() + "'";
        psql += " order by c.cust_area,c.cust_seq desc";

        this_init();

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                if (JSONdata.length > 0) {

                    $("#cust_seq").val(item.cust_seq);
                    $("#now_cust_seq").val(item.cust_seq);
                    $("#apsqlno").val(item.apsqlno);
                    $("#apcust_no").val(item.apcust_no);

                    $("#ap_cname").val(item.ap_cname1+item.ap_cname2);
                    $("#pscode").val(item.pscode);
                    $("#pscodenm").val(item.pscodenm);
                    $("#tscode").val(item.tscode);
                    $("#tscodenm").val(item.tscodenm);
                    $("#apsqlno").val(item.apsqlno);
                }
                else {
                    //window.parent.tt.rows = "100%, 0%";//cust45list & cust46list用
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


    function custzSave() {


        //說明備註==============================
        //部門
        for (var xx=1;xx<=CInt($("#htext_sql").val());xx++){
            $("#txt_dept_value_"+xx).val(getCheckedValue("#tabText>tbody input[name='txt_dept_"+xx+"']:checked"));
            //var v = "|";
            //$("input[type=checkbox][name='txt_dept_"+xx+"']:checked").each(function () {
            //    v += $(this).val() + "|";
            //})
            //$("#txt_dept_value_"+xx).val(v);
        }

        //相關檔案==============================
        //種類
        for (var xx=1;xx<=CInt($("#hattach_sql").val());xx++){
            $("#attach_mremark_value_"+xx).val(getCheckedValue("#tabAttach>tbody input[name='attach_mremark_"+xx+"']:checked"));
            //var v = "|";
            //$("input[type=checkbox][name='attach_mremark_"+xx+"']:checked").each(function () {
            //    v += $(this).val() + "|";
            //})
            //$("#attach_mremark_value_"+xx).val(v);
        }


        //標記update flag//////////////////////////////////////////////////////////////////////
        //報表備註==============================
        for (var r=1;r<=nReport;r++){
            $("#rpt_upd_flag_"+r).val("");
            if($("#rpt_mark_sqlno_"+r).val()!=""){//有流水號表示DB有資料
                if($("input[name=rpt_syscode_"+r+"]:checked").val()!=$("#o_rpt_syscode_"+r).val()
                    ||$("#rpt_mark_type2_"+r).val()!=$("#o_rpt_mark_type2_"+r).val()
                    ||$("#rpt_att_sql_"+r).val()!=$("#o_rpt_att_sql_"+r).val()
                    ||$("input[name=rpt_spe_mark1_"+r+"]:checked").val()!=$("#o_rpt_spe_mark1_"+r).val()
                    ||$("#rpt_end_date_"+r).val()!=$("#o_rpt_end_date_"+r).val()
                    )
                {
                    $("#rpt_upd_flag_"+r).val("Y");
                }
            }
        }

        //說明備註==============================
        for (var r=1;r<=CInt($("#htext_sql").val());r++){
            $("#txt_upd_flag_"+r).val("");
            if($("#txt_mark_sqlno_"+r).val()!=""){//有流水號表示DB有資料
                if($("#txt_dept_value_"+r).val()!=$("#o_txt_dept_"+r).val()
                    ||$("#txt_mark_type2_"+r).val()!=$("#o_txt_mark_type2_"+r).val()
                    ||$("#txt_att_sql_"+r).val()!=$("#o_txt_att_sql_"+r).val()
                    ||$("#txt_type_content1_"+r).val()!=$("#o_txt_type_content1_"+r).val()
                    ||$("#txt_end_date_"+r).val()!=$("#o_txt_end_date_"+r).val()
                    )
                {
                    $("#txt_upd_flag_"+r).val("Y");
                }
            }
        }

        //相關檔案==============================
        for (var r=1;r<=CInt($("#hattach_sql").val());r++){
            $("#attach_upd_flag_"+r).val("");
            if($("#attach_apattach_sqlno_"+r).val()!=""){//有流水號表示DB有資料
                if($("#attach_name_"+r).val()!=$("#o_attach_name_"+r).val()
                    ||$("#attach_source_name_"+r).val()!=$("#o_attach_source_name_"+r).val()
                    ||$("#attach_mremark_value_"+r).val()!=$("#o_attach_mremark_"+r).val()
                    ||$("#attach_desc_"+r).val()!=$("#o_attach_desc_"+r).val()
                    ){
                    $("#attach_upd_flag_"+r).val("Y");
                }
            }
        }

      
        //資料檢查//////////////////////////////////////////////////////////////////////
        var errMsg="";
        var objRpt = {},objTxt = {},objAttach = {};
	
        ////報表備註==============================
        for (var r=1;r<=nReport;r++){
            if(!$("#rpt_del_"+r).prop('checked')){
                var lineOpt=getJoinValue("#reportlist>tbody input[name='rpt_syscode_"+r+"']:checked,#rpt_mark_type2_"+r+",#rpt_att_sql_"+r);
                if(objRpt[lineOpt]) {
                    errMsg+="[報表備註] "+r+". 與 "+objRpt[lineOpt].idx+". 選項重覆\n";
                }else{
                    objRpt[lineOpt]={flag : true, idx:r};
                }
            }
        }
        ////說明備註==============================
        for (var r=1;r<=CInt($("#htext_sql").val());r++){
            if(!$("#txt_del_"+r).prop('checked')){
                if($("#txt_type_content1_"+r).val()=="")errMsg+="[說明備註] "+r+". 須輸入說明\n";
                if($("#txt_dept_value_"+r).val()=="||")errMsg+="[說明備註] "+r+". 須選擇部門\n";
			
                var lineOpt=getJoinValue("#txt_dept_value_"+r+",#txt_mark_type2_"+r+",#txt_att_sql_"+r);
                if(objTxt[lineOpt]) {
                    errMsg+="[說明備註] "+r+". 與 "+objTxt[lineOpt].idx+". 選項重覆\n";
                }else{
                    objTxt[lineOpt]={flag : true, idx:r};
                }
            }
        }
        //相關檔案==============================
        for (var r=1;r<=CInt($("#hattach_sql").val());r++){
            if(!$("#attach_del_"+r).prop('checked')){
                if($("#attach_mremark_value_"+r).val()=="||")errMsg+="[相關檔案] "+r+". 須選擇種類\n";
                if($("#attach_name_"+r).val()==""||$("#attach_source_name_"+r).val()==""){
                    errMsg+="[相關檔案] 附件"+r+". 須上傳檔案\n";
                }else if($("#attach_desc_"+r).val()==""){
                    errMsg+="[相關檔案] 附件"+r+". 須輸入說明\n";
                }
            }
        }

        //計算異動筆數//////////////////////////////////////////////////////////////////////
        if(CInt($("#htext_sql").val()) + CInt($("#hattach_sql").val()) + nReport == 0){
            errMsg+="無資料可存檔\n";
        }
	
        if (errMsg!=""){
            alert(errMsg);
            return false;
        }


        //****改用ajax,才不用處理update後導頁面
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust23_Update.aspx",formData)
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
        custzSave();
    });


    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();

    });

    //取得勾選的值
    function getCheckedValue(selector){
        return "|"+$(selector).map(function (){
            return $(this).val();
        }).get().join('|')+"|";//前後都包起來
    }

    function SetReportmarkReadOnly() {
        $("input[type=checkbox][id^='rpt_del_']").hide();
        $("#AddReport_button").hide();
        $("select[id^='rpt_mark_type2_']").lock();
        $("select[id^='rpt_att_sql_']").lock();
        $("input[type=radio][name^='rpt_spe_mark1']").lock();
        $("input[type=text][name^='rpt_end_date']").lock();
    }


</script>
