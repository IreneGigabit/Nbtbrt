<%@ Control Language="C#" ClassName="brt15form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>

<script runat="server">
    //官收後續交辦欄位畫面
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_toadd = "";

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

        //案性分類
        SQL += "SELECT Cust_code,Code_name,form_name,mark";
        SQL += " FROM Cust_code";
        SQL += " WHERE Code_type = '" + Sys.getRsType() + "' AND form_name is not null ";
        SQL += "order by cust_code";
        html_toadd = Util.Option(conn, SQL, "{Cust_code}", "{Code_name}", " v1='{form_name}'", false, "", "mark=S");
        
        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        if ((submitTask == "Q" || submitTask == "D")) {
            Lock["brt15Lock"] = "Lock";
        }
        dmt_upload_Form.uploadsource = "grconf_cs";
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<input type=hidden name=job_case id=job_case>
<TABLE id=tab15 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>後&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;續&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;交&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>  
	<TR >
		<TD class=lightbluetable align=right >作業處理：</TD>
		<TD class=whitetablebg colspan=5 ><input type=hidden name="job_no" id="job_no">
			<label><input type=radio name="job_type" value="case" class="<%#Lock.TryGet("brt15Lock")%>" onclick="brt15form.showtr()">接洽客戶後續案性</label>
			<label><input type=radio name="job_type" value="endr" class="<%#Lock.TryGet("brt15Lock")%>" onclick="brt15form.showtr()">結辦歸檔</label>
		</td>
	</TR>
	<TR id="showcase1" style="display:none">
		<TD class=lightbluetable align=right >洽案登錄：</TD>
		<TD class=whitetablebg colspan=5 >
			<SELECT name="toadd" id="toadd" class="<%#Lock.TryGet("brt15Lock")%>" onchange="brt15form.toadd_onchange1()">
			    <option value="" style="color:blue">請選擇案性</option>
			    <%#html_toadd%>
			</SELECT>
		</td>
	</TR>
	<TR >
		<TD class=lightbluetable align=right >預計處理日期：</TD>
		<TD class=whitetablebg colspan=5>
			<input type=text name="pre_date" id="pre_date" size=10 class="dateField <%#Lock.TryGet("brt15Lock")%>">
		</td>
	</TR>
	<TR >
		<TD class=lightbluetable align=right >交辦事項說明：</TD>
		<TD class=whitetablebg colspan=5>
			<textarea cols=60 rows=5 name=sales_remark id=sales_remark class="<%#Lock.TryGet("brt15Lock")%>"></textarea>
		</td>
	</TR>
	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>自&nbsp;&nbsp;&nbsp;&nbsp;行&nbsp;&nbsp;&nbsp;&nbsp;報&nbsp;&nbsp;&nbsp;&nbsp;導&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;件&nbsp;&nbsp;&nbsp;&nbsp;上&nbsp;&nbsp;&nbsp;&nbsp;傳&nbsp;&nbsp;&nbsp;&nbsp;</font></TD>
    </TR>
	<TR >
		<TD class=lightbluetable align=right >自行客戶報導：</TD>
		<TD class=whitetablebg colspan=5><input type=hidden name="ocs_report" id="ocs_report">
			<label><input type=radio name="cs_report" value="Y" class="<%#Lock.TryGet("brt15Lock")%>" onclick="brt15form.cs_report_onclick1(this.value)">需</label>
			<label><input type=radio name="cs_report" value="N" class="<%#Lock.TryGet("brt15Lock")%>" onclick="brt15form.cs_report_onclick1(this.value)">不需</label>
		</td>
	</TR>
</TABLE>
<span id='spbpuppload' style="display:none">
    <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" /><!--文件上傳畫面-->
</span>	

<script language="javascript" type="text/javascript">
    var brt15form = {};

    brt15form.init = function () {
        upload_form.init();
    }

    brt15form.bind = function (jData, jAttach) {
        $("#job_case").val(jData.job_case);
        $("#job_no").val(jData.job_no);
        $("input[name='job_type'][value='" + jData.job_type + "']").prop("checked", true).triggerHandler("click");
        $("#toadd option[value='" + jData.job_case + "']").prop("selected", true);
        $("#toadd").triggerHandler("change");
        $("#pre_date").val(jData.pre_date);
        $("#sales_remark").val(jData.sales_remark);
        $("#ocs_report").val(jData.cs_report);
        $("input[name='cs_report'][value='" + jData.cs_report + "']").prop("checked", true).triggerHandler("click");
        upload_form.bind(jAttach);//顯示上傳文件

        if (jData.job_type == "case" && jData.job_no != "") {
            $("input[name='job_type']").lock();
            $("#toadd").lock();
            $("#pre_date").lock();
        }
    }

    //作業處理
    brt15form.showtr = function () {
        $("#showcase1").hide();
        if ($("input[name='job_type']:checked").val() == "case") {//接洽客戶後續案性
            $("#showcase1").show();
        }
    }

    //洽案登錄案性
    brt15form.toadd_onchange1 = function () {
        var job_case = $("#toadd option:selected").attr("v1") || "";
        $("#job_case").val(job_case);
    }

    //預計處理日期
    $("#pre_date").change(function () {
        ChkDate($("#pre_date")[0]);
        if($('#pre_date').val()=="") return false;
        var pre_date = CDate($('#pre_date').val());
        if (pre_date.getTime() < Today().getTime()) {
            alert("預計處理日期不可小於今天！");
            $('#pre_date').focus();
        }
    });

    //自行客戶報導
    brt15form.cs_report_onclick1 = function (pvalue) {
        if (pvalue == "Y") {
            $("#spbpuppload").show();
        }else if (pvalue == "N") {
            $("#spbpuppload").hide();
        }
    }
</script>
