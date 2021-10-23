<%@ Control Language="C#" ClassName="brt71main_form" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string html_company = "", td_tscode = "", html_att_sql="";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        //收據開立
        SQL = "select ar_code,ar_company from account.dbo.ar_code where code_type='ar_code' and branch='_' and dept='_' and (end_date is null or end_date>=getdate()) ";
        html_company = Util.Option(conn, SQL, "{ar_code}", "{ar_company}", true);

        //營洽清單
        DataTable dt = new DataTable();
        if ((HTProgRight & 64) != 0) {
            SQL = "select scode,sc_name from sysctrl.dbo.vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
            conn.DataTable(SQL, dt);
            td_tscode = "<select id='Scode' name='Scode' disabled>" + dt.Option("{scode}", "{scode}_{sc_name}", true) + "</select>";
        } else {
            td_tscode = "<input type='text' id='Scode' name='Scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
            td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
        }

        //聯絡人
        string tcust_seq = "";
        if (ReqVal.TryGet("tfx_cust_seq") == "") {
            tcust_seq = ReqVal.TryGet("cust_seq");
        } else {
            tcust_seq = ReqVal.TryGet("tfx_cust_seq");
        }
        SQL = "SELECT Att_sql, Attention FROM custz_Att ";
        SQL += "where Cust_area='" + Session["seBranch"] + "' and (Cust_seq ='" + tcust_seq + "') and (att_code like 'N%' or att_code='' or att_code is null) and dept='" + Session["Dept"] + "' ";
        html_att_sql = Util.Option(conn, SQL, "{Att_sql}", "{Att_sql}_{Attention}", true);

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
    <TR>
		<TD class="lightbluetable" width="10%">收據種類：</TD>
		<td class=whitetablebg colspan=3>
			<input type=text id=hdcompany name=hdcompany>
			<select id="company" name="company" onchange="brt71main_form.search_acc('I')"><%#html_company%></select>
			*收據開立: <span id="span_tar_mark"></span>
		</td>    
		<td class="lightbluetable" width="10%">收據營洽：</td>
		<td class=whitetablebg><%#td_tscode%></td>
	</TR>
	<tr>
		<TD class="lightbluetable">向誰請款：</TD>
		<td class=whitetablebg colspan=3><input type="text" id="cust_area" name="cust_area" size=1 readonly class="sedit" value=<%=Session["seBranch"]%>>-
			<input type="text" id="tfx_cust_seq" name="tfx_cust_seq" readonly class="sedit" size=5>
            <span id="span_cust_remark"></span>
			<input type="text" id="ap_cname" name="ap_cname" size=60 readonly class="sedit">
			<input type="text" id="cust_spay_flag" name="cust_spay_flag" value="N">
			<input type="text" id="cust_spay_mm" name="cust_spay_mm" value=0>
		</td>    
		<TD class="lightbluetable" >聯絡人：</TD>
		<td class=whitetablebg>
            <select id="att_sql" name="att_sql" onchange="brt71main_form.search_addr()"><%#html_att_sql%></select>
		</td>	
	</tr>
	<tr>	
		<TD class="lightbluetable">請款地址：</TD>
		<td  class=whitetablebg colspan=3><!--2010/4/28蔡協理Email4/26修改不能修改地址，權限C可修改-->
			<input type="text" name="ar_zip" id="ar_zip" size=8>
			<input type="text" name="ar_addr1" id="ar_addr1" size=30 maxlength=60>
			<input type="text" name="ar_addr2" id="ar_addr2" size=30 maxlength=60>
		</td>
		<td class="lightbluetable">開單日期：</td>
		<td class=whitetablebg><input type="text" id="in_date" name="in_date" size="10" readonly class="SEdit"></td>
	</tr>
	<tr>	
		<TD class="lightbluetable">收據抬頭：</TD>
		<td  class=whitetablebg colspan=3>
			<input type="text" name="apclass" id="apclass"><span id="span_ap_cname"></span>
		</td>
		<td class="lightbluetable" STYLE="COLOR:BLUE" title="預定回收日，請填電匯日、現金收回日、支票回收日...等"><u style="color:blue">預定回收日：</u></td>
		<td class=whitetablebg><input type="text" id="rdate" name="rdate" size="10" class="dateField"></td>
	</tr>
	<tr>
		<TD class="lightbluetable">請款備註：</TD>
		<td class=whitetablebg colspan=5>
			<label><input type=radio name="ar_chk" value="N" onclick="brt71main_form.ar_chk71()">不顯示</label>
			<label><input type=radio name="ar_chk" value="Y" onclick="brt71main_form.ar_chk71()">要顯示：請於</label>
			<input type="text" id="pdate" name="pdate" size="10" class="dateField">前給付，
			約定票期<input type="text" id="acchk_date" name="acchk_date" size="10" class="dateField">
            </td>
	</tr>
	<tr>
		<TD class="lightbluetable">電匯帳號：</TD>
		<td class=whitetablebg colspan=5>
			<label><input type=radio name="acc_chk" value="N">不顯示</label>
			<label><input type=radio name="acc_chk" value="Y">要顯示：電匯請匯至</label>
			<input type=text name="acc_name" id="acc_name" size=80 maxlength=80 readonly>
        </td>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var brt71main_form={};
    brt71main_form.init = function () {
    }

    brt71main_form.bind = function (jData) {
        $("#hdcompany").val(jData.ar_main.ar_company);
        $("#company").val(jData.ar_main.ar_company).triggerHandler("change");
        //收據開立
        if (jData.ar_main.tar_mark == "D") {
            $("#span_tar_mark").html("<font color=red>扣收入不開收據</font>");
        } else {
            $("#span_tar_mark").html("需開收據");
        }
        //向誰請款
        $("#tfx_cust_seq").val(jData.ar_main.cust_seq);
        $("#span_cust_remark").html(jData.ar_main.cust_remark);//客戶備註圖示
        $("#ap_cname").val(jData.ar_main.cust_name);
        //聯絡人
        $("#att_sql option[value='" + jData.ar_main.att_sql + "']").prop("selected", true);
        //請款地址
        $("#ar_zip").val(jData.ar_main.att_zip);
        if ((main.right & 256) == 0) {//2010/4/28蔡協理Email4/26修改不能修改地址，權限C可修改
            $("#att_zip,#ar_addr1,#ar_addr2").lock();
        }
        $("#ar_addr1").val(jData.ar_main.att_addr1);
        $("#ar_addr2").val(jData.ar_main.att_addr2);
        //開單日期
        $("#in_date").val(Today().format("yyyy/M/d"));
        //收據抬頭
        $("#apclass").val(jData.ar_main.apclass);
        $("#span_ap_cname").html(jData.ar_main.apcust_no + "-- " + jData.ar_main.ap_cname);
        //請款備註
        $("input[name='ar_chk'][value='" + jData.request.ar_chk + "']").prop("checked", true);
        //電匯帳號
        $("input[name='acc_chk'][value='" + jData.request.acc_chk + "']").prop("checked", true);
        $("#acc_name").val(jData.ar_main.acc_name);
    }

    //選擇收據種類
    brt71main_form.search_acc = function (t) {
        if (t == "I") {
            if ($("#company").val() == "I") {
                alert("國內案之收據種類不能開立「聖島智產」！");
                $("#company").val($("#hdcompany").val());
                return false;
            }
            if ($("#company").val() != $("#hdcompany").val()) {
                alert("收據種類與所內規定不同，如要更改應取得核准！");
            }
        }

        //*******抓取收據抬頭對應之電匯帳號
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_ar_code.aspx",
            data: { code_type: "ar_code", ar_code: $("#company").val(), branch: "<%=Session["seBranch"]%>", dept: "_" },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert("無該收據抬頭之電匯帳號!!");
                    return false;
                } else {
                    $("#acc_name").val(JSONdata[0].acc_name);
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取收據抬頭對應之電匯帳號失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取收據抬頭對應之電匯帳號失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    brt71main_form.search_addr = function () {
        //*******抓取連絡人之連絡地址
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_custz_att.aspx",
            data: { cust_area: $("#cust_area").val(), cust_seq: $("#tfx_cust_seq").val(), att_sql: $("#att_sql").val() },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert("無該連絡人連絡地址資料!!");
                    return false;
                } else {
                    $("#ar_zip").val(JSONdata[0].att_zip);
                    $("#ar_addr1").val(JSONdata[0].att_addr1);
                    $("#ar_addr2").val(JSONdata[0].att_addr2);
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取連絡人之連絡地址失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取連絡人之連絡地址失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //檢查請款備註
    brt71main_form.ar_chk71 = function () {
        if ($("input[name='ar_chk']:checked").val() == "N") {//不顯示
            $("#pdate").val("");
            $("#acchk_date").val("");
        }
        if ($("input[name='ar_chk']:checked").val() == "Y") {//要顯示
            if ($("#pdate").val() == "" && $("#acchk_date").val() == "") {
                alert("點選顯示請款備註，請輸入給付日期及約定票期！");
                return false;
            }
        }
    }
</script>
