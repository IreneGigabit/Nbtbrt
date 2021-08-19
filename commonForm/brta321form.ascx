<%@ Control Language="C#" ClassName="brta321form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //本發欄位畫面
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_send_way = "";

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

        html_send_way = Sys.getCustCode("SEND_WAY", "", "cust_code").Option("{cust_code}", "{code_name}");
        
        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tabgs border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
    	<TR>
		<TD align=center colspan=4 class=lightbluetable1><font color=white>發&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>狀態：</TD>
		<TD class=whitetablebg>
			<input type="hidden" id="rs_no" name="rs_no">
			<input type="hidden" id="cgrs" name="cgrs">
			<input type="text" id="scgrs" name="scgrs" size=4 class=sedit readonly>
		</TD>
		<TD class=lightbluetable align=right>發文日期：</TD>
		<TD class=whitetablebg><input type="text" id="step_date" name="step_date" size="10" class="dateField <%=Lock.TryGet("QLock")%>"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>發文代碼：</TD>
		<TD class=whitetablebg>結構分類：
			<input type="hidden" name="rs_type" id="rs_type">
            <select name="rs_class" id="rs_class" class="<%=Lock.TryGet("QLock")%>"></select>
			案性：
			<span id=span_rs_code>
                <select name="rs_code" id="rs_code" class="<%=Lock.TryGet("QLock")%>"></select>
			</span><br>
			處理事項：
			<input type="hidden" id="act_sqlno" name="act_sqlno">
			<select name="act_code" id="act_code" class="<%=Lock.TryGet("QLock")%>"></select>
		</TD>
		<TD class=lightbluetable align=right>本次狀態：</TD>
		<TD class=whitetablebg>
            <input type="hidden" id="ncase_stat" name="ncase_stat">
			<input type="text" id="ncase_statnm" name="ncase_statnm" size="10" class=sedit readonly>
		</TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>發文內容：</TD>
		<TD class=whitetablebg colspan=3><input type="text" id="rs_detail" name="rs_detail" size=60 class="<%=Lock.TryGet("QLock")%>"></TD>
	</TR>
	<TR id=tr_send>	
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg>
			<SELECT id=send_way name=send_way class="<%=Lock.TryGet("QLock")%>"><%=html_send_way%></SELECT>
		</TD>
		<TD class=lightbluetable align=right>法定期限：</TD>
		<TD class=whitetablebg >
		    <input type="text" id="last_date" name="last_date" size="10" class="dateField <%=Lock.TryGet("QLock")%>">
		</TD>
	</TR>
</table>

<script language="javascript" type="text/javascript">
    var brta321form = {};

    brta321form.init = function () {
    }

    brta321form.bind = function (jData) {
        $("#rs_no").val(jData.rs_no);
        $("#cgrs").val(jData.cgrs.toUpperCase()).triggerHandler("change");
        $("#step_date").val(jData.step_date);
        $("#rs_type").val(jData.rs_type).triggerHandler("change");
        $("#rs_class_name").val(jData.rs_class_name);
        $("#rs_code_name").val(jData.rs_code_name);
        $("#rs_class option[value='" + jData.rs_class + "']").prop("selected", true);
        $("#rs_class").triggerHandler("change");
        $("#rs_code option[value='" + jData.rs_code + "']").prop("selected", true);
        $("#rs_code").triggerHandler("change");
        $("#act_sqlno").val(jData.act_sqlno);
        if ((jData.act_code || "") == "") {
            $("#act_code option[value='_']").prop("selected", true);
        } else {
            $("#act_code option[value='" + jData.act_code + "']").prop("selected", true);
        }
        $("#act_code").triggerHandler("change");
        if (jData.rs_detail != undefined) $("#rs_detail").val(jData.rs_detail);
        $("#send_way option[value='" + jData.send_way + "']").prop("selected", true);
        $("#last_date").val(jData.last_date);
    }

    $("#cgrs").change(function () {
        $("#scgrs").val("客發");
    });

    //依rs_type帶結構分類
    $("#rs_type").change(function () {
        $("#rs_class").getOption({//結構分類
            url: getRootPath() + "/ajax/json_rs_class.aspx",
            data: { rs_type: $("#rs_type").val(), cg:"C", rs: "S" },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}",
            attrFormat: "vref_code='{ref_code}'"
        });
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        if ($(this).val() != "") {
            $("#rs_class_name").val($("#rs_class option:selected").text());
        }

        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_type: $("#rs_type").val(), submittask: $("#submittask").val() || "" },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}' vfees='{fees}' vmark='{mark}' vrs_agtno='{rsagtno}' vrs_agtnm='{receipt}_{rsagtnm}'"
        });
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#rs_detail,#rs_code_name").val("");
        if ($(this).val() != "") {
            $("#rs_detail,#rs_code_name").val($("#rs_code option:selected").text());
        }

        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { cgrs: $("#cgrs").val(), rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        $("#ncase_statnm").val("");
        $("#act_code option[value='_']").prop("selected", true);
        $("#act_code").triggerHandler("change");
    });

    //依處理事項帶本次狀態/管制
    $("#act_code").change(function () {
        if ($(main.submittask == "A")) {
            if ($("#act_code option:selected").val() != "" && $("#act_code option:selected").val() != "_") {
                $("#rs_detail").val($("#rs_code option:selected").text() + $("#act_code option:selected").text());
            }
        }

        //取得案性設定
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_act_sqlno.aspx?cgrs=" + $("#cgrs").val() + "&rs_class=" + $("#rs_class").val() + "&rs_code=" + $("#rs_code").val() + "&act_code=" + $("#act_code").val(),
            async: false,
            cache: false,
            success: function (json) {
                var jAct = $.parseJSON(json);
                $.each(jAct, function (i, item) {
                    $("#ncase_stat").val(item.case_stat);
                    $("#ncase_statnm").val(item.case_statnm);
                    $("#act_sqlno").val(item.ctrl_sqlno);
                })
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案性設定載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案性設定載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    });

    $(".dateField").blur(function () {
        ChkDate($(this)[0]);
    });
</script>
