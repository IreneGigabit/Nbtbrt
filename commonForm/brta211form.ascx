<%@ Control Language="C#" ClassName="brta211form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //官收欄位畫面
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_send_cl = "", html_receive_way = "", html_send_way = "", html_cs_remark_code = "";
    protected string html_pr_scode="",html_send_sel = "", html_pay_times = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim().ToUpper();

        html_send_cl = Sys.getCustCode("SEND_CL", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_receive_way = Sys.getCustCode("Treceive_way", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_send_way = Sys.getCustCode("SEND_WAY", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_cs_remark_code = Sys.getCustCode("Tcs_remark", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_pr_scode = Sys.getPrScode().Option("{scode}", "{scode}_{sc_name}", "", false);
        html_pay_times = Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}");

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tabbr style="display:" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<%if(prgid == "brta24"){%>
	<TR><!--程序官收確認-->
		<TD align=right colspan=6 class=whitetablebg>
			<input type=button name="getmgstep" id="getmgstep" class="c1button" value="重新抓取總收發官收及管制資料" onclick="brta211form.GetmgStep()">
		</TD>
	</TR>
	<%}%>
	<TR>
		<TD class=lightbluetable align=right>進度序號：</TD>
		<TD class=whitetablebg>
			<input type="hidden" id="mg_step_grade" name="mg_step_grade" />
			<input type="hidden" id="mg_rs_sqlno" name="mg_rs_sqlno" />
			<input type="hidden" id="rs_no" name="rs_no">
			<input type="text" id="nstep_grade" name="nstep_grade" size="2" class="SEdit" readonly>
			<input type="hidden" id="cgrs" name="cgrs">
			<select id=scgrs name=scgrs class="<%=Lock.TryGet("Qdisabled")%>">
				<option value="GR">官收</option>
			</select> 
		</TD>
		<TD class=lightbluetable align=right>收文日期：</TD>
		<TD class=whitetablebg ><input type="text" id="step_date" name="step_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
		<TD class=lightbluetable align=right>總收文日期：</TD>
		<TD class=whitetablebg ><input type="text" id="mp_date" name="mp_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
	<TR>	
		<TD class=lightbluetable align=right>來文單位：</TD>
		<TD class=whitetablebg >
			<SELECT name=send_cl id=send_cl class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_cl%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>來文字號：</TD>
		<TD class=whitetablebg ><input type="text" id="receive_no" name="receive_no" size=20 maxlength=20  class="<%=Lock.TryGet("Qdisabled")%>"></TD>
		<TD class=lightbluetable align=right>來文方式：</TD>
		<TD class=whitetablebg >
			<select name="receive_way" id="receive_way" class="<%=Lock.TryGet("Qdisabled")%>"><%=html_receive_way%></SELECT>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right><font color=blue>總管處收文內容：</font></TD>
		<TD class=whitetablebg colspan=5>
            <input type="text" id="mg_rs_detail" name="mg_rs_detail" size=60 class="sedit" readonly>
            <span id="span_mg_attach"></span>
            <script type="text/html" id="mg_attach_template"><!--收文文件樣版-->
                <img id="imgdetail1Doc_##" name="imgdetail1Doc_##" onclick="brta211form.pdf_click(##)" src="../images/top/doc.gif" border="0"  style="cursor:pointer">
                <input type="hidden" id="pdfpath_##" name="pdfpath_##">
                <input type="hidden" id="pdfname_##" name="pdfname_##" />
                <input type="hidden" id="preview_pdfpath_##" name="preview_pdfpath_##">
                <input type="hidden" id="pdfviewflag_##" name="pdfviewflag_##" value="N"><!--有無點選電子檔-->
            </script>
			<input type="hidden" id="pdfcnt" name="pdfcnt">
			<input type="hidden" id="pdfchkflag" name="pdfchkflag">
			<input type="hidden" id="pdfsource" name="pdfsource">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>收文代碼：</TD>
		<TD class=whitetablebg colspan=5>結構分類：
			<input type="hidden" name="rs_type" id="rs_type">
			<input type="hidden" name="rs_class_name" id="rs_class_name">
			<input type="hidden" name="rs_code_name" id="rs_code_name">
			<input type="hidden" name="act_code_name" id="act_code_name">
			<span id=span_rs_class>
			    <select name="rs_class" id="rs_class" class="<%=Lock.TryGet("Qdisabled")%>"></select>
			</span>
			案性代碼：
			<span id=span_rs_code>
				<select name="rs_code" id="rs_code" class="<%=Lock.TryGet("Qdisabled")%>"></select>
			</span><br>
			處理事項：
			<input type="hidden" name="act_sqlno" id="act_sqlno">
			<span id=span_act_code>
				<select name="act_code" id="act_code" class="<%=Lock.TryGet("Qdisabled")%>"></select>
			</span>
			&nbsp;&nbsp;&nbsp;&nbsp;本次狀態：
			<input type="hidden" name="ocase_stat" id="ocase_stat" size="10">
			<input type="hidden" name="ncase_stat" id="ncase_stat" size="10">
			<input type="text" name="ncase_statnm" id="ncase_statnm" size="10" class="sedit <%=Lock.TryGet("Qdisabled")%>" readonly>
		</TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>收文內容：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="rs_detail" id="rs_detail" size=60 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
    <TR>
		<TD class=lightbluetable align=right>附件：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="doc_detail" id="doc_detail" size=60 maxlength=60 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>掃描文件：</TD>
		<TD class=whitetablebg colspan=5>
            <label><input type="radio" name="pr_scan" value="Y" class="<%=Lock.TryGet("Qdisabled")%>">需要</label>
            <label><input type="radio" name="pr_scan" value="N" class="<%=Lock.TryGet("Qdisabled")%>">不需要</label>
            ，共<input type=text name="pr_scan_page" id="pr_scan_page" size=3 class="<%=Lock.TryGet("Qdisabled")%>" >頁&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            說明：<input type=text name="pr_scan_remark" id="pr_scan_remark" class="<%=Lock.TryGet("Qdisabled")%>" size=60 ></label>
            <input type=hidden name="pr_scan_path" id="pr_scan_path">
            <input type=button value="檢視" class="cbutton" onclick="brta211form.Previewprscan()">
		</TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>客戶報導：</TD>
		<TD class=whitetablebg>
            <label><input type=radio name=csflg class="<%=Lock.TryGet("Qdisabled")%>" value="Y" onclick="brta211form.csflg_onclick()">需要</label>
            <label><input type=radio name=csflg class="<%=Lock.TryGet("Qdisabled")%>" value="N" onclick="brta211form.csflg_onclick()">不需要</label>
            <input type=checkbox name=csd_flag id=csd_flag class="<%=Lock.TryGet("Qdisabled")%>" value="Y" onclick="brta211form.csd_flag_onclick()">要延期客發
            <input type="hidden" name="cs_rs_no" id="cs_rs_no">
            <input type="hidden" name="cs_flag" id="cs_flag" value="N"><!--是否有制式客函,N無,Y有-->
			<input id="btnPreviewcsreport" type=button value="檢視" class="cbutton" onclick="brta211form.Previewcsreport()"> 
		</TD>							   
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg>
			<SELECT name="send_way" id="send_way" class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_way%></select>
		</TD>
		<TD class=lightbluetable align=right>承辦：</TD>
		<TD class=whitetablebg>
			<SELECT name="pr_scode" id="pr_scode" class="<%=Lock.TryGet("Qdisabled")%>">
                <OPTION style="COLOR: blue" selected value="">不需承辦</OPTION>
                <%=html_pr_scode%>
			</SELECT>
		</TD>
	</TR>
	<TR id="tr_csremark" style="display:none">
		<TD class=lightbluetable align=right>原因：</TD>
		<TD class=whitetablebg colspan=5>
		    <span id="sp_cs_remark_code">
		        <SELECT name="cs_remark_code" id="cs_remark_code" class="<%=Lock.TryGet("Qdisabled")%>"><%=html_cs_remark_code%>
		        </select>(不需客戶報導或延期客發，請填寫原因)<br>
		    </span>
		    <input type="text" name="cs_remark" id="cs_remark" size=60 maxlength=255 class="<%=Lock.TryGet("Qdisabled")%>">
        </TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>客戶報導主旨：</TD>
		<TD class=whitetablebg colspan=3><input type="text" name="cs_detail" id="cs_detail" maxlength=60 style="width:95%" class="<%=Lock.TryGet("Qdisabled")%>"></TD>
		<TD class=lightbluetable align=right>預定寄發日期：</TD>
		<TD class=whitetablebg><input type="text" name="pmail_date" id="pmail_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
	<tr id="tr_csmail_date" style="display:none">
		<TD class=lightbluetable align=right>寄出日期：</TD>
		<TD class=whitetablebg colspan=3><input type="text" name="mail_date" id="mail_date" size="10" readonly class="sedit">
	    <input type=hidden name="mail_scode" id="mail_scode">
	    (確認日期：<input type="text" name="mwork_date" id="mwork_date" size="24" readonly class="sedit">，
		 確認人員：<input type="text" name="mail_scname" id="mail_scname" size="8" readonly class="sedit">)</td>
		<TD class=lightbluetable align=right>列印日期：</TD>
		<TD class=whitetablebg ><input type="text" name="print_date" id="print_date" style="width:95%" readonly class="sedit"></td> 
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var brta211form = {};

    brta211form.init = function () {
    }

    brta211form.bind = function (jData,jMGAttach) {
        $("#mg_step_grade").val(jData.mg_step_grade);
        $("#mg_rs_sqlno").val(jData.mg_rs_sqlno);
        $("#rs_no").val(jData.rs_no);
        $("#nstep_grade").val(jData.nstep_grade);
        $("#cgrs").val(jData.cgrs);
        $("#scgrs").val(jData.cgrs);
        $("#step_date").val(jData.step_date);
        $("#mp_date").val(jData.mp_date);
        $("#send_cl option[value='" + jData.send_cl + "']").prop("selected", true);
        $("#receive_no").val(jData.receive_no);
        $("#receive_way option[value='" + jData.receive_way + "']").prop("selected", true);
        //總管處收文內容
        $("#mg_rs_detail").val(jData.mg_rs_detail);
        $("#pdfsource").val(jData.pdfsource);
        if (jMGAttach != null) {
            $("#pdfcnt").val(jMGAttach.length);
            $("#pdfchkflag").val(jMGAttach.length > 0 ? "Y" : "N");
            if (jMGAttach.length > 0) {
                if (jData.pdfsource == "EGR") {
                    $("#span_mg_attach").append("<font color=red>智慧局公文電子檔：</font>");
                } else {
                    $("#span_mg_attach").append("<font color=red>Email/上傳公文電子檔：</font>");
                }
                brta211form.appendMGAttach(jMGAttach);//總管處文件append到畫面
            }
        }
        $("#rs_type").val(jData.rs_type).triggerHandler("change");
        $("#rs_class_name").val(jData.rs_class_name);
        $("#rs_code_name").val(jData.rs_code_name);
        $("#act_code_name").val(jData.act_code_name);
        $("#rs_class option[value='" + jData.rs_class + "']").prop("selected", true);
        $("#rs_class").triggerHandler("change");
        $("#rs_code option[value='" + jData.rs_code + "']").prop("selected", true);
        $("#rs_code").triggerHandler("change");
        $("#act_code option[value='"+jData.act_code+"']").prop("selected", true);
        $("#act_code").triggerHandler("change");
        $("#act_sqlno").val(jData.act_sqlno);
        $("#ocase_stat").val(jData.ocase_stat);
        $("#ncase_stat").val(jData.ncase_stat);
        $("#ncase_statnm").val(jData.ncase_statnm);
        $("#rs_detail").val(jData.rs_detail);
        $("#doc_detail").val(jData.doc_detail);
        $("#pr_scan_page").val(jData.pr_scan_page);
        $("#pr_scan_remark").val(jData.pr_scan_remark);
        $("#pr_scan_path").val(jData.pr_scan_path);
        $("#cs_rs_no").val(jData.cs_rs_no);
        $("#send_way,#csd_flag").lock();
        if ((jData.cs_rs_no||"") != "") {
            $("#btnPreviewcsreport").show();
            $("input[name='csflg'][value='Y']").prop("checked", true);
            $("#send_way,#cs_detail,#csd_flag").unlock();
            $("#cs_flag").val("Y");
        } else {
            $("#btnPreviewcsreport").hide();
            $("input[name='csflg'][value='N']").prop("checked", true);
            $("#send_way,#cs_detail,#csd_flag").lock();
        }
        $("input[name='csflg']:checked").triggerHandler("click");
        $("input[name='csd_flag'][value='" + jData.csd_flag + "']").prop("checked", true);
        $("#csd_flag:checked").triggerHandler("click");

        $("#send_way option[value='" + jData.send_way + "']").prop("selected", true);
        $("input[name='pr_scan'][value='" + jData.pr_scan + "']").prop("checked", true);
        $("#pr_scode option[value='" + jData.pr_scode + "']").prop("selected", true);
        $("#cs_remark_code").val(jData.cs_remark_code);
        $("#cs_remark").val(jData.cs_remark);
        $("#cs_detail").val(jData.cs_detail);
        $("#pmail_date").val(jData.pmail_date);
        $("#mail_date").val(jData.mail_date);
        $("#mail_scode").val(jData.mail_scode);
        $("#mwork_date").val(jData.mwork_date);
        $("#mail_scname").val(jData.mail_scname);
        $("#print_date").val(jData.print_date);

        if ($("#cs_remark").val() != "") {
            $("#tr_csremark").show();
        } else {
            $("#tr_csremark").hide();
        }
    }

    //依rs_type帶結構分類
    $("#rs_type").change(function () {
        $("#rs_class").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: {
                sql: "select cust_code,code_name from cust_code where code_type='" + $("#rs_type").val() + "' and mark is null " +
				      " and cust_code in (select rs_class from vcode_act where cg ='G' and rs = 'R') order by cust_code"
            },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_type: $("#rs_type").val() },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}'"
        });
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        $("#ncase_stat").val("");
        $("#ncase_statnm").val("");
    });

    //依處理事項帶本次狀態/管制
    $("#act_code").change(function () {
        $("#act_code_name").val($( "#act_code option:selected").text());
        $("#ncase_stat,#ncase_statnm").val("");
        $("#rs_detail").val($("#rs_code option:selected").text());

        if ($("#act_code option:selected").val() != "" && $("#act_code option:selected").val() != "_") {
            $("#rs_detail").val($("#rs_detail").val() + $("#act_code option:selected").text());
        }

        brta211form.getCtrl();//帶預設期限

        if (main.submittask != "Q") {
            //註冊費繳納期數與發文案性關聯性檢查
            switch ($("#act_code").val()) {
                case "F1":
                    if ($("#opay_times").val() != "" && $("#opay_times").val() != "1") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第一期 』?");
                        if (ans != true) {
                            $("#act_code").focus();
                            return false;
                        } else {
                            $("#pay_times").val("1");
                            $("#hpay_times").val("1");
                            $("#pay_date").val($("#step_date").val());
                        }
                    } else {
                        //2009/1/9相同則依案件主檔，案件主檔無日期才依官收日期
                        $("#pay_times").val("1");
                        $("#hpay_times").val("1");
                        if ($("#opay_date").val() == "") {
                            $("#pay_date").val($("#step_date").val());
                        } else {
                            $("#pay_date").val($("#opay_date").val());
                        }
                    }
                    break;
                case "F2":
                    if ($("#opay_times").val() != "1" && $("#opay_times").val() != "2") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 第二期 』?");
                        if (ans != true) {
                            $("#act_code").focus();
                            return false;
                        } else {
                            $("#pay_times").val("2");
                            $("#hpay_times").val("2");
                            $("#pay_date").val($("#step_date").val());
                        }
                    } else {
                        $("#pay_times").val("2");
                        $("#hpay_times").val("2");
                        //2009/1/9相同則依案件主檔，案件主檔無日期才依官收日期
                        if ($("#opay_date").val() == "") {
                            $("#pay_date").val($("#step_date").val());
                        } else {
                            $("#pay_date").val($("#opay_date").val());
                        }
                    }
                    break;
                case "F0":
                    if ($("#opay_times").val() != "" && $("#opay_times").val() != "A") {
                        var ans = confirm("註冊費已繳期數與發文案性不符, 是否將註冊費已繳期數更正為『 全期 』?");
                        if (ans != true) {
                            $("#act_code").focus();
                            return false;
                        } else {
                            $("#pay_times").val("A");
                            $("#hpay_times").val("A");
                            $("#pay_date").val($("#step_date").val());
                        }
                    } else {
                        $("#pay_times").val("A");
                        $("#hpay_times").val("A");
                        //2009/1/9相同則依案件主檔，案件主檔無日期才依官收日期
                        if ($("#opay_date").val() == "") {
                            $("#pay_date").val($("#step_date").val());
                        } else {
                            $("#pay_date").val($("#opay_date").val());
                        }
                    }
                    break;
                case "Y0":
                    if ($("#opay_times").val() == "") {
                        $("#pay_times").val("1");
                        $("#hpay_times").val("1");
                        //2009/1/9相同則依案件主檔，案件主檔無日期才依官收日期
                        if ($("#opay_date").val() == "") {
                            $("#pay_date").val($("#step_date").val());
                        } else {
                            $("#pay_date").val($("#opay_date").val());
                        }
                    }
                    break;
                default:
                    $("#pay_times").val($("#opay_times").val());
                    $("#hpay_times").val($("#opay_times").val());
                    $("#pay_date").val($("#opay_date").val());
                    break;
            }
        }
    });

    //產生預設期限/案性管制設定
    brta211form.getCtrl = function () {
        if(main.submittask=="A"){
            brta212form.empty_ctrl();//onchange觸發多次會有多筆.先清空管制期限
            //取得案性管制設定
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_act_sqlno.aspx?cgrs=" + $("#cgrs").val()+ "&rs_class=" + $("#rs_class").val()+"&rs_code=" + $("#rs_code").val()+"&act_code=" + $("#act_code").val(),
                async: false,
                cache: false,
                success: function (json) {
                    var jCtrl = $.parseJSON(json);
                    $.each(jCtrl, function (i, item) {
                        if(item.sqlflg=="A"){
                            $("#ctrl_flg").val("Y");//有預設期限管制
                            $("#act_sqlno").val(item.ctrl_sqlno);
                            brta212form.add_ctrl(true);
                            $("#ctrl_type_"+$("#ctrlnum").val()).val(item.ctrl_type);//管制種類
                            $("#ctrl_remark_"+$("#ctrlnum").val()).val(item.ctrl_remark);//管制內容
                            var days=0;//管制天數
                            if(item.ad=="A"){//日期基礎:A:加，D:減 
                                days=CInt(item.days);
                            }else{
                                days=CInt(item.days)*-1;
                            }
                            var days2=0;//管制天數
                            if(item.ad2=="A"){//日期基礎:A:加，D:減 
                                days2=CInt(item.days2);
                            }else{
                                days2=CInt(item.days2)*-1;
                            }
                       
                            var md=item.md;//管制性質
                            var md2=item.md2;//管制性質
                            var date_ctrl=$("#"+item.date_name).val()||"";//基準日期欄位
                            if(date_ctrl==""){
                                alert("管制天數之基準日期未輸入, 請輸入!!");
                                $("#act_sqlno").val("");
                                $("#"+item.date_name).focus();
                            }

                            var Cdate_ctrl=CDate(date_ctrl);
                            if(md.toUpperCase()=="D"){
                                Cdate_ctrl=Cdate_ctrl.addDays(days);
                            }else if(md.toUpperCase()=="M"){
                                Cdate_ctrl=Cdate_ctrl.addMonths(days);
                            }else if(md.toUpperCase()=="Y"){
                                Cdate_ctrl=Cdate_ctrl.addYears(days);
                            }

                            if(item.ad2!=""){
                                if(md2.toUpperCase()=="D"){
                                    Cdate_ctrl=Cdate_ctrl.addDays(days2);
                                }else if(md2.toUpperCase()=="M"){
                                    Cdate_ctrl=Cdate_ctrl.addMonths(days2);
                                }else if(md2.toUpperCase()=="Y"){
                                    Cdate_ctrl=Cdate_ctrl.addYears(days2);
                                }
                            }

                            $("#ctrl_date_"+$("#ctrlnum").val()).val(Cdate_ctrl.format("yyyy/M/d"));//管制日期

                            if(item.csflg=="Y"){
                                $("input[name='csflg'][value='Y']").prop("checked",true);
                                $("#send_way").unlock();
                                $("#cs_detail").val(item.cs_detail).unlock();
                                $("#cs_flag").val("Y");
                                $("#csd_flag").unlock();
                            }
                            $("#ncase_stat").val(item.case_stat);
                            $("#ncase_statnm").val(item.case_statnm);
                        }else{
                            $("#ctrl_flg").val("N");//無預設期限管制
                            brta212form.add_ctrl(false);
                            $("#ctrl_type_1").val("A1");//新增一筆法定期限
                            if(item.csflg=="Y"){
                                $("input[name='csflg'][value='Y']").prop("checked",true);
                                $("#send_way").unlock();
                                $("#cs_detail").val(item.cs_detail).unlock();
                                $("#cs_flag").val("Y");
                                $("#csd_flag").unlock();
                            }
                            $("#ncase_stat").val(item.case_stat);
                            $("#ncase_statnm").val(item.case_statnm);
                        }
                        if($("input[name='csflg']:checked").val()!="Y"){
                            $("input[name='csflg'][value='N']").prop("checked",true);
                            $("#send_way").lock();
                            $("#cs_detail").val("").lock();
                            $("#csd_flag").lock();
                            $("#pmail_date").val("");
                        }
                    })
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>案性管制載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '案性管制載入失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
        }

        if(main.submittask=="U"||main.submittask=="Q"){
            //取得案性管制設定
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_act_sqlno.aspx?cgrs=" + $("#cgrs").val()+ "&rs_class=" + $("#rs_class").val()+"&rs_code=" + $("#rs_code").val()+"&act_code=" + $("#act_code").val(),
                async: false,
                cache: false,
                success: function (json) {
                    var jCtrl = $.parseJSON(json);
                    $.each(jCtrl, function (i, item) {
                        if(item.sqlflg=="A"){
                            if(main.prgid=="brta24"){//程序官收確認
                                $("#ctrl_flg").val("Y");//有預設期限管制
                                $("#act_sqlno").val(item.ctrl_sqlno);
                                brta212form.add_ctrl(true);
                                $("#ctrl_type_"+$("#ctrlnum").val()).val(item.ctrl_type);//管制種類
                                $("#ctrl_remark_"+$("#ctrlnum").val()).val(item.ctrl_remark);//管制內容
                                var days=0;//管制天數
                                if(item.ad=="A"){//日期基礎:A:加，D:減 
                                    days=CInt(item.days);
                                }else{
                                    days=CInt(item.days)*-1;
                                }
                                var days2=0;//管制天數
                                if(item.ad2=="A"){//日期基礎:A:加，D:減 
                                    days2=CInt(item.days2);
                                }else{
                                    days2=CInt(item.days2)*-1;
                                }
                       
                                var md=item.md;//管制性質
                                var md2=item.md2;//管制性質
                                var date_ctrl=$("#"+item.date_name).val()||"";//基準日期欄位
                                if(date_ctrl==""){
                                    alert("管制天數之基準日期未輸入, 請輸入!!");
                                    $("#act_sqlno").val("");
                                    $("#"+item.date_name).focus();
                                }

                                var Cdate_ctrl=CDate(date_ctrl);
                                if(md.toUpperCase()=="D"){
                                    Cdate_ctrl=Cdate_ctrl.addDays(days);
                                }else if(md.toUpperCase()=="M"){
                                    Cdate_ctrl=Cdate_ctrl.addMonths(days);
                                }else if(md.toUpperCase()=="Y"){
                                    Cdate_ctrl=Cdate_ctrl.addYears(days);
                                }

                                if(item.ad2!=""){
                                    if(md2.toUpperCase()=="D"){
                                        Cdate_ctrl=Cdate_ctrl.addDays(days2);
                                    }else if(md2.toUpperCase()=="M"){
                                        Cdate_ctrl=Cdate_ctrl.addMonths(days2);
                                    }else if(md2.toUpperCase()=="Y"){
                                        Cdate_ctrl=Cdate_ctrl.addYears(days2);
                                    }
                                }

                                $("#ctrl_date_"+$("#ctrlnum").val()).val(Cdate_ctrl.format("yyyy/M/d"));//管制日期
                            }

                            if(item.csflg=="Y"){
                                $("input[name='csflg'][value='Y']").prop("checked",true);
                                $("#send_way").unlock();
                                $("#cs_detail").val(item.cs_detail).unlock();
                                $("#cs_flag").val("Y");
                                $("#csd_flag").unlock();
                                if($("#pmail_date").val()==""){
                                    var mp_date = CDate($("#mp_date").val());
                                    $("#pmail_date").val(mp_date.addDays(7).format("yyyy/M/d"));
                                }
                            }
                            $("#ncase_stat").val(item.case_stat);
                            $("#ncase_statnm").val(item.case_statnm);
                        }else{
                            if(item.csflg=="Y"){
                                $("input[name='csflg'][value='Y']").prop("checked",true);
                                $("#send_way").unlock();
                                $("#cs_detail").val(item.cs_detail).unlock();
                                $("#cs_flag").val("Y");
                                $("#csd_flag").unlock();
                                if($("#pmail_date").val()==""){
                                    var mp_date = CDate($("#mp_date").val());
                                    $("#pmail_date").val(mp_date.addDays(7).format("yyyy/M/d"));
                                }
                            }
                            $("#ncase_stat").val(item.case_stat);
                            $("#ncase_statnm").val(item.case_statnm);
                        }
                        if($("input[name='csflg']:checked").val()!="Y"){
                            $("input[name='csflg'][value='N']").prop("checked",true);
                            $("#send_way").lock();
                            $("#cs_detail").val("").lock();
                            $("#csd_flag").lock();
                            $("#pmail_date").val("");
                        }
                    })
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>案性管制載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '案性管制載入失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
        }
    }

    //客戶報導
    brta211form.csflg_onclick = function () {
        if($("input[name='csflg']:checked").val()=="Y"){//需要
            $("#cs_detail").unlock();//客戶報導主旨
            $("#send_way").unlock();//發文方式
            $("#csd_flag").unlock();//要延期客發
            if($("#pmail_date").val()==""){
                var mp_date = CDate($("#mp_date").val());
                $("#pmail_date").val(mp_date.addDays(7).format("yyyy/M/d"));
            }
        }
        if($("input[name='csflg']:checked").val()=="N"){//不需要
            $("#cs_detail").lock();//客戶報導主旨
            $("#send_way").lock();//發文方式
            $("#csd_flag").lock();//要延期客發
            if ($("#cs_flag").val() == "Y") {//有制式客函
                $("#tr_csremark").show();
            } else {
                $("#tr_csremark").hide();
                $("#pmail_date").val("");//預定寄發日期
            }
        }
    }
  
    //要延期客發
    brta211form.csd_flag_onclick = function () {
        if ($("#csd_flag").prop("checked")==true) {
            $("#tr_csremark").show();
        } else {
            $("#tr_csremark").hide();
        }
    }

    $("#step_date,#mp_date,#pmail_date").blur(function () {
        ChkDate($(this)[0]);
    });

    //重新抓取總收發文之官方收文代碼
    brta211form.GetmgStep=function(){
        if (confirm("是否確定重新取得總收發官方收文資料？")){
            var url = getRootPath() + "/ajax/brta21_Get_mgstep.aspx?prgid=<%=prgid%>&cgrs=GR&temp_rs_sqlno="+$("#temp_rs_sqlno").val()+"&mg_step_rs_sqlno="+$("#mg_rs_sqlno").val()+"&qbranch=<%=Session["seBranch"]%>&qseq="+$("#seq").val()+"&qseq1="+$("#seq1").val();
            ajaxScriptByGet("重新取得總收發官方收文資料", url);
        }
    }

    //檢視文件掃描
    brta211form.Previewprscan=function(){
        if($("#pr_scan_page").val()==""){
            alert("文件尚未掃描!!!");
            return false;
        }else{
            if(CInt($("#pr_scan_page").val())==0){
                alert("文件尚未掃描!!!");
                return false;
            }else{
                if($("#pr_scan_path").val()==""){
                    alert("文件尚未掃描!!!");
                    return false;
                }
            }
        }
        window.open($("#pr_scan_path").val());
    }

    //檢視客戶函定稿
    brta211form.Previewcsreport=function(){
        if($("#cs_rs_no").val()==""){
            alert("尚未產生客戶函!!!");
            return false;
        }
        window.open("/nbtbrt/brtam/brta522Print.aspx?prgid=<%=prgid%>&closewin=Y&srs_no="+$("#cs_rs_no").val()+"&ers_no="+$("#cs_rs_no").val()+"&sseq="+$("#seq").val()+"&eseq="+$("#seq").val(),"myWindowOneN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no, scrollbars=yes,titlebar=no");
    }

    //客函不需寄發或延期寄發原因代碼
    $("#cs_remark_code").change(function () {
        $("#cs_remark").val($( "#cs_remark_code option:selected").text());
    });

    //檢視電子公文	
    brta211form.pdf_click=function(pno){
        window.open($("#preview_pdfpath_" + pno).val());
	
        //有點選電子檔
        $("#pdfviewflag_"+pno).val("Y");
        $("#imgdetail1Doc_"+pno).attr("src", getRootPath() + "/images/ok.gif");
    }

    //總管處文件append到畫面
    brta211form.appendMGAttach = function (jData) {
        $.each(jData, function (i, item) {
            var nRow = (i + 1);
            //複製樣板
            var copyStr = $("#mg_attach_template").text() || "";
            copyStr = copyStr.replace(/##/g, nRow);
            $("#span_mg_attach").append(copyStr);
            $('#pdfpath_' + nRow).val(item.attach_path);
            $('#pdfname_' + nRow).val(item.attach_name);
            $('#preview_pdfpath_' + nRow).val(item.view_path);
            if (item.source == "EGR") {
                $('#imgdetail1Doc_' + nRow).attr("title", "顯示電子公文資料");
            } else {
                $('#imgdetail1Doc_' + nRow).attr("title", "顯示Email/上傳資料");
            }
        });
    }
</script>
