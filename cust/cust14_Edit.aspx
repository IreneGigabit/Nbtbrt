<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust13Form.ascx" TagPrefix="uc1" TagName="cust13Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>

<script runat="server">

    protected string HTProgCap = "更正客戶申請人作業";//功能名稱
    private string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "cust14";//程式檔名前綴
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string submitTask = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string DebugStr = "";
    protected string apsqlno = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string titlenm = "";
    //申請人國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    //申請人種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    protected string needchk = "N";
    protected string prgid = HttpContext.Current.Request["prgid"];
    
    //protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    protected bool HideC = true;
    
    private void Page_Unload(System.Object sender, System.EventArgs e)
    {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        //ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        apsqlno = Request["apsqlno"];
        submitTask = Request["submitTask"];
        
        if ((Request["cust_area"] ?? "") != "") cust_area = Request["cust_area"];
        if ((Request["cust_seq"] ?? "") != "") cust_seq = Request["cust_seq"]; ;

        titlenm = (Request["kind"] == "custz") ? "客戶" : "申請人";
        if (Request["kind"] == "custz") HTProgCap = "更正客戶申請人作業";
        if (Request["kind"] == "apcust") HTProgCap = "更正申請人作業";

        if (Request["gs_dept"] == "T")
        {
            CheckDmt();
        }
        //CheckDmt();
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";
        

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        DebugStr = myToken.DebugStr;

        if (HTProgRight >= 0)
        {
            if (HTProgRight >= 256) HideC = false;
            QueryPageLayout();
            this.DataBind();
        }
    }

    private void QueryPageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            //有固定的用法.class=imgCls會自動觸發關閉視窗
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

    private void CheckDmt()
    { 
        //若未更正案件主檔不可再更正客戶申請人
        //'因內商於SQL修改案件申請人，需控制
        using (DBHelper conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST"))
        {
            SqlDataReader dr = conn.ExecuteReader("select seq,seq1 from dmt where apsqlno="+ Request["apsqlno"]);
            if (dr.HasRows)
            {
                dr.Close(); dr.Dispose();
                SqlDataReader dr2 = conn.ExecuteReader("select * from apcust_log where chg_dept='" + Request["gs_dept"] + "' and apsqlno=" + Request["apsqlno"]);
                if (dr2.HasRows) needchk = "Y";
                else needchk = "N";
                dr2.Close(); dr2.Dispose();
            }
            else
            {
                needchk = "N";
            }
            dr.Close(); dr.Dispose();
        }
    }
    
    
    

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<body>
    <form id="reg" name="reg" method="post" action="">
    <div>
    <input TYPE="hidden" name="prgid" value="<%=prgid%>">
<input TYPE="hidden" name="gs_dept" value="<%=Request["gs_dept"]%>">
<input TYPE="hidden" name="kind" value="<%=Request["kind"]%>">
<input TYPE="hidden" name="havemaindata" value="<%=Request["havemaindata"]%>">
<input TYPE="hidden" name="cust_area" value="<%=Request["cust_area"]%>">
<input TYPE="hidden" name="cust_seq" value="<%=Request["cust_seq"]%>">
<input TYPE="hidden" name="apsqlno" value="<%=Request["apsqlno"]%>">
<input TYPE="hidden" name="qcust_area" value="<%=Request["qcust_area"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qcust_seqs" value="<%=Request["qcust_seqs"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qcust_seqe" value="<%=Request["qcust_seqe"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qapclass" value="<%=Request["qapclass"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qapcust_no" value="<%=Request["qapcust_no"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qap_cname" value="<%=Request["qap_cname"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qap_ename" value="<%=Request["qap_ename"]%>"><!--查詢條件-->
<input TYPE="hidden" name="qap_country" value="<%=Request["qap_country"]%>"><!--查詢條件-->
    <table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【cust14_Edit <%#HTProgCap%>】&nbsp;&nbsp;
        </td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
    </table>
    <center>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable1" align="center" colspan="4"><font color=white>原&nbsp;&nbsp;&nbsp;&nbsp;始&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;料</font></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">客戶編號：</td>
		<td class="whitetablebg" colspan=3><%=cust_area%>-<%=cust_seq%></td>
	</tr>
	<tr id="tr_custz">
		<td class="lightbluetable" align="right" width="18%">證照編號：</td>
		<td class="whitetablebg" colspan=3>
            <input TYPE="text" NAME="apcust_no" id="apcust_no" class="SEdit" readonly value="" size="30">
		</td>
	</tr>
	<tr id="tr_apcust">
		<td class="lightbluetable" align="right">申請人編號：</td>
		<td class="whitetablebg">
            <input TYPE="text" NAME="apcust_no" id="apcust_no2" class="SEdit" readonly value="" size="30">
		</td>
		<td class="lightbluetable" align="right">申請人流水號：</td>
		<td class="whitetablebg"><%=apsqlno%></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" width="18%"><%=titlenm%>種類：</td>
		<td class="whitetablebg" align="left" width="40%">
            <input TYPE="text" NAME="apclass" id="apclass" class="SEdit" readonly value="" size="30">
		</td>
		<td class="lightbluetable" align="right" width="16%"><%=titlenm%>國籍：</td>
		<td class="whitetablebg" align="left" width="28%">
            <input TYPE="text" NAME="ap_country" id="ap_country" class="SEdit" readonly value="">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
            <input type="text" id="ap_cname1" name="ap_cname1" class="SEdit" readonly />
            <input type="text" id="ap_cname2" name="ap_cname2" class="SEdit" readonly />
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
            姓：<input type="text" id="ap_fcname" name="ap_fcname" class="SEdit" readonly />
            名：<input type="text" id="ap_lcname" name="ap_lcname" class="SEdit" readonly />
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
            <input type="text" id="ap_ename1" name="ap_ename1" class="SEdit" readonly size="30" />
            <input type="text" id="ap_ename2" name="ap_ename2" class="SEdit" readonly />
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
            姓：<input type="text" id="ap_fename" name="ap_fename" class="SEdit" readonly />
            名：<input type="text" id="ap_lename" name="ap_lename" class="SEdit" readonly />
		</td>
	</tr>
</table>
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable1" align="center" colspan="4"><font color=white>更&nbsp;&nbsp;&nbsp;&nbsp;正&nbsp;&nbsp;&nbsp;&nbsp;內&nbsp;&nbsp;&nbsp;&nbsp;容&nbsp;&nbsp;(<font color=Pink>不須更正之資料不需輸入</font>)</font></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" width="18%"><%=titlenm%>種類：</td>
		<td class="whitetablebg" align="left" width="40%">
			<input TYPE="hidden" NAME="apclass_name" value="<%=titlenm%>種類">
			<input TYPE="hidden" id="oapclass" NAME="oapclass">
			<input TYPE="hidden" NAME="fidname1" value="apclass">
			<input type=checkbox name="chgtype" disabled>
			<select id="napclass" name="napclass" size="1" ><%=html_apclass %></select>
		</td>
		<td class="lightbluetable" align="right" width="16%"><%=titlenm%>國籍：</td>
		<td class="whitetablebg" align="left" width="28%">
			<input TYPE="hidden" NAME="ap_country_name" value="<%=titlenm%>國籍">
			<input TYPE="hidden" id="oap_country" NAME="oap_country" >
			<input TYPE="hidden" NAME="fidname2" value="ap_country">
			<input type=checkbox name="chgtype" disabled>
			<select id="nap_country" name="nap_country" size="1" onchange="nap_country_onchange()">
				<option value="T">T_中華民國</option>
                <%=html_country %>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%#(Request["kind"] == "custz")?"證照":"申請人"%>編號：</td>
		<td class="whitetablebg" colspan=3>
			<input TYPE="hidden" NAME="apcust_no_name" value="證照編號">
			<input TYPE="hidden" id="oapcust_no" NAME="oapcust_no" SIZE="10" MAXLENGTH="10" >
			<input TYPE="hidden" NAME="fidname3" value="apcust_no">
			<input type=checkbox name="chgtype" disabled>
			<input TYPE="text" id="napcust_no" NAME="napcust_no" onblur="napcust_no_onblur()" SIZE="11" MAXLENGTH="10">
			<div id="msgChgType2" style="color:red"></div>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_cname1_name" value="<%=titlenm%>名稱(中)1">
		<input TYPE="hidden" NAME="ap_cname2_name" value="<%=titlenm%>名稱(中)2">
		<input TYPE="hidden" id="ap_cname" NAME="ap_cname">
		<input TYPE="hidden" id="oap_cname1" NAME="oap_cname1">
		<input TYPE="hidden" id="oap_cname2" NAME="oap_cname2">
		<input TYPE="hidden" NAME="fidname4" value="ap_cname1">
		<input TYPE="hidden" NAME="fidname5" value="ap_cname2">
		<input type=checkbox name="chgtype" disabled>
		<input TYPE="text" id="nap_cname1" NAME="nap_cname1" size="44" maxlength="44" onblur="nap_cname1_onblur()">
		<input TYPE="text" id="nap_cname2" NAME="nap_cname2" size="44" maxlength="44" onblur="nap_cname2_onblur()">
		<div id="msgChgType3" style="color:red"></div>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_fcname_name" value="<%=titlenm%>名稱(中)姓">
		<input TYPE="hidden" NAME="ap_lcname_name" value="<%=titlenm%>名稱(中)名">
		<input TYPE="hidden" id="oap_fcname" NAME="oap_fcname" >
		<input TYPE="hidden" id="oap_lcname" NAME="oap_lcname" >
		<input TYPE="hidden" NAME="fidname8" value="ap_fcname">
		<input TYPE="hidden" NAME="fidname9" value="ap_lcname">
		<input type=checkbox name="chgtype" disabled>
		姓：<input TYPE="text" id="nap_fcname" NAME="nap_fcname" size="15" maxlength="15">
		名：<input TYPE="text" id="nap_lcname" NAME="nap_lcname" size="15" maxlength="15">
		<div id="msgChgType4" style="color:red"></div>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_ename1_name" value="<%=titlenm%>名稱(英)1">
		<input TYPE="hidden" NAME="ap_ename2_name" value="<%=titlenm%>名稱(英)2">
		<input TYPE="hidden" id="oap_ename1" NAME="oap_ename1" >
		<input TYPE="hidden" id="oap_ename2" NAME="oap_ename2" >
		<input TYPE="hidden" NAME="fidname6" value="ap_ename1">
		<input TYPE="hidden" NAME="fidname7" value="ap_ename2">
		<input type=checkbox name="chgtype" disabled>
		<input TYPE="text" id="nap_ename1" NAME="nap_ename1" size="60" maxlength="100"><br>
		&nbsp;&nbsp;&nbsp;&nbsp;<input TYPE="text" id="nap_ename2" NAME="nap_ename2" size="60" maxlength="100">
		<input type=checkbox name="chgnull">空白
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><%=titlenm%>名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
		<input TYPE="hidden" NAME="ap_fename_name" value="<%=titlenm%>名稱(英)姓">
		<input TYPE="hidden" NAME="ap_lename_name" value="<%=titlenm%>名稱(英)名">
		<input TYPE="hidden" id="oap_fename" NAME="oap_fename">
		<input TYPE="hidden" id="oap_lename" NAME="oap_lename">
		<input TYPE="hidden" NAME="fidname10" value="ap_fename">
		<input TYPE="hidden" NAME="fidname11" value="ap_lename">
		<input type=checkbox name="chgtype" disabled>
		姓：<input TYPE="text" NAME="nap_fename" size="33" maxlength="30">
		名：<input TYPE="text" NAME="nap_lename" size="33" maxlength="30">
		<input type=checkbox name="chgnull2">空白
		</td>
	</tr>
	<input TYPE="hidden" id="upd_main" NAME="upd_main">
	<tr id="tr_Status">
		<td class="lightbluetable" align="right">狀態：</td>
		<td class="whitetablebg" colspan="3">
		<input type=radio name="rupd_main">需更正
		<input type=radio name="rupd_main" >不需更正
		<input type=radio name="rupd_main" >已更正案件主檔申請人資料
		</td>
	</tr>
</table>

    </center>
    </div>
        <%#DebugStr%>
    </form>
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

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
        if ('<%=HideC%>' == "False") {
            $("#tr_Status").show();
        }
        
        if ('<%=needchk%>' == "Y") {
            if (confirm("尚有案件未更正客戶申請人資料，請確定是否繼續")) {
            }
            else {
                window.parent.tt.rows = "100%,0%";
                return false;
            }
        }

        loadData();
        chkInvmain();
        if ('<%=Request["kind"]%>' == "custz") {
            $("#tr_apcust").hide();
        }
        else {
            $("#tr_custz").hide();
        }
        //if ($("#submitTask").val() == "A")
        //{
        //}
        //if ($("#submitTask").val() == "U" || $("#submitTask").val() == "Q") {
        //    $("#txtapclass").show();
        //    loadData();
        //    SetReadOnly();
        //}
        //if ($("#submitTask").val() == "Q") {
        //}

    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,70%";

            $("#tr_Status").hide();
        }
    }

    function SetReadOnly() {
        //$("#apclass, #ap_country, #apcust_no").lock();
        //$("#ap_cname1, #ap_cname2, #ap_fcname, #ap_lcname").lock();
    }

    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
    });


    //[存檔]
    $("#btnSave").click(function (e) {
        var gosubmit = false;

        if ($("#nap_country").val() != "" && $("#oap_country").val() != $("#nap_country").val()) {
            reg.chgtype[1].checked = true;
        }
        for (var i = 0; i < 7; i++) {
            if (reg.chgtype[i].checked == false) {
                switch (i) {

                    case 3:
                        reg.fidname4.value = "";
                        reg.fidname5.value = "";
                        break;
                    case 4:
                        reg.fidname8.value = "";
                        reg.fidname9.value = "";
                        break;
                    case 5:
                        reg.fidname6.value = "";
                        reg.fidname7.value = "";
                        break;
                    case 6:
                        reg.fidname10.value = "";
                        reg.fidname11.value = "";
                        break;
                    default:
                        var n = i + 1;
                        $("input[name=fidname" + n + "]").val("a");
                        break;
                }
            }
            else {
                gosubmit = true;//有變動資料
            }
        }

        nap_cname1_onblur();
        nap_cname2_onblur();

        if ($("#oap_ename1").val() != "" || $("#oap_ename2").val() != "") {
            if (reg.chgnull.checked == true) {//英文名稱為空白
                reg.chgtype[5].checked = true;
                reg.fidname6.value = "ap_ename1";
                reg.fidname7.value = "ap_ename2";
                gosubmit = true;
            }
        }
        else {
            reg.chgnull.checked = false;
        }
        if ($("#oap_fename").val() != "" || $("#oap_lename").val() != "") {
            if (reg.chgnull2.checked == true) {//英文名稱為空白
                reg.chgtype[6].checked = true;
                reg.fidname10.value = "ap_fename";
                reg.fidname11.value = "ap_lename";
                gosubmit = true;
            }
        }
        else {
            reg.chgnull2.checked = false;
        }

        var ap_cname = "";
        var ap_flname = "";
        if ($.trim($("#nap_fcname").val()) != "" || $.trim($("#nap_lcname").val()) != "") {
            if ($.trim($("#nap_cname1").val()) != "" || $.trim($("#nap_cname2").val()) != "") {
                ap_cname = $.trim($("#nap_cname1").val()) + $.trim($("#nap_cname2").val());
            }
            else {
                ap_cname = $.trim($("#ap_cname").val());
            }
            ap_flname = $.trim($("#nap_fcname").val()) + $.trim($("#nap_lcname").val());
            if (ap_cname != ap_flname) {
                alert("客戶或申請人「姓」及「名」必須等於客戶或申請人名稱全名!");
                return false;
            }
        }

        //20180518增加檢查-原證照編號是否已開立發票
        //申請人編號.申請人名稱(中)1&2
        if (reg.chgtype[2].checked == true || reg.chgtype[3].checked == true || reg.chgtype[4].checked == true) {

            var psql = "select count(*)cc from account.dbo.invmain where inv_id='" + reg.oapcust_no.value + "' and tran_code='N' ";
            $.ajax({
                url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
                type: "POST",
                async: false,
                cache: false,
                data: $("#reg").serialize(),
                success: function (json) {
                    var JSONdata = $.parseJSON(json);
                    var item = JSONdata[0];
                    if (CInt(item.cc) > 0) {

                        if (<%#(HTProgRight & 64)%> > 0 || <%#(HTProgRight & 128)%> > 0 || <%#(HTProgRight & 256)%> > 0) {
                            if (confirm("原證照編號已開立發票，是否確定修改？")) {
                            }
                            else {
                                return false;
                            }
                        }
                        else {
                            alert("原證照編號已開立發票，如確定修改，則請先與會計確認後再通知資訊部開放修改權限。");
                            return false;
                        }
                    }
                },
                beforeSend: function (jqXHR, settings) {
                    jqXHR.url = settings.url;
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
                }
            });

            gosubmit = true;
        }

        if (<%#(HTProgRight & 128)%> > 0) {
            if ($("input[name='rupd_main']")[0].checked == false || $("input[name='rupd_main']")[1].checked == false || $("input[name='rupd_main']")[2].checked == false) {
                alert("狀態需勾選!");
                return false;
            }
            if ($("input[name='rupd_main']")[0].checked == true) {$("#upd_main").val("Y");}
            if ($("input[name='rupd_main']")[1].checked == true) {$("#upd_main").val("N");}
            if ($("input[name='rupd_main']")[2].checked == true) {$("#upd_main").val("U");}
        }

        if (($("#napclass").val().substring(0, 1) == $("#oapclass").val().substring(0, 1)) && $("#napcust_no").val() == "" && $("#oapcust_no").val() != "") {}
        else {
            //AC-->AB可不需輸ID
            if (("AB,AC,AD,AE").indexOf($("#napclass").val()) > 0 || $("#napclass").val() == "CB" || $("#napclass").val() == "CT") {
                if ($("#oapcust_no").val() == "" && $("#napcust_no").val() == "") {
                    alert("ID 必須輸入 !");
                    return false;
                }
            }
            if (napcust_no_onblur2() == true) {
                $("#napcust_no").focus();
                return false;
            }
            if (NulltoEmpty($("#napcust_no").val()) == "") {
                switch ($("#napclass").val()) {
                    case "AB":
                    case "AC":
                    case "AD":
                    case "AE":
                        if (chkID($("#oapcust_no").val(), "TaxID") == true) {
                            return false;
                        }
                        break;

                    case "B":
                        if (chkID($("#oapcust_no").val(), "ID") == true) {
                            return false;
                        }
                        break;

                    case "CB":
                        if (fChkDataLen2($("#oapcust_no")[0], 10, "證照編號") == "") {
                            return false;
                        }
                        break;

                    case "CT":
                        if (fChkDataLen2($("#oapcust_no")[0], 6, "證照編號") == "") {
                            return false;
                        }
                        break;
                    default:
                        break;
                }
            }

    
        }



























        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust14_Update.aspx",formData)
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
                        }
                    }
                }
            });
        });

    });//btnSave End

    function loadData() {

        var psql = "select apsqlno,cust_area,cust_seq,apcust_no,apclass,ap_country,ap_cname1,ap_cname2,ap_ename1,ap_ename2,";
        psql += "ap_fcname,ap_lcname,ap_fename,ap_lename, ";
        psql += "(select code_name from cust_code where code_type='apclass' and cust_code=a.apclass) as apclassnm, ";
        psql += "(select coun_c from sysctrl.dbo.country where coun_code=a.ap_country) as countrynm ";
        //客戶更名
        if ('<%=Request["kind"]%>' == "custz") {
            psql += "from vcustlist a where cust_area='<%=Request["cust_area"]%>' and cust_seq='<%=Request["cust_seq"]%>'";
        }
        //申請人更名
        if ('<%=Request["kind"]%>' == "apcust") {
            psql += "from apcust a where apsqlno='<%=Request["apsqlno"]%>'";
        }


        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];

                $("#apcust_no, #apcust_no2").val(item.apcust_no);
                $("#oapcust_no").val(item.apcust_no);
                $("#apclass").val(item.apclass + "-" + item.apclassnm);
                $("#oapclass").val(item.apclass);
                $("#ap_country").val(item.ap_country + "-" + item.countrynm);
                $("#oap_country").val(item.ap_country);
                $("#ap_cname1").val(item.ap_cname1);
                $("#ap_cname2").val(item.ap_cname2);
                $("#ap_fcname").val(item.ap_fcname);
                $("#ap_lcname").val(item.ap_lcname);
                $("#ap_cname").val(item.ap_cname1 + item.ap_cname2);
                $("#ap_ename1").val(item.ap_ename1); 
                $("#ap_ename2").val(item.ap_ename2);
                $("#ap_fename").val(item.ap_fename); 
                $("#ap_lename").val(item.ap_lename); 
                $.trim($("#oap_cname1").val(item.ap_cname1));
                $.trim($("#oap_cname2").val(item.ap_cname2));
                $.trim($("#oap_fcname").val(item.ap_fcname));
                $.trim($("#oap_lcname").val(item.ap_lcname));
                $.trim($("#oap_ename1").val(item.ap_ename1));
                $.trim($("#oap_ename2").val(item.ap_ename2));
                $.trim($("#oap_fename").val(item.ap_fename));
                $.trim($("#oap_lename").val(item.ap_lename));
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }


    function chkInvmain() {
        //20180518增加檢查-原證照編號是否已開立發票
        var msg = "";
        var psql = "select count(*)cc from account.dbo.invmain where inv_id='" + reg.oapcust_no.value + "' and tran_code='N' ";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                if (CInt(item.cc) > 0) {
                    msg = "原證照編號已開立發票，如確定修改，則請先與會計確認後再通知資訊部開放修改權限。";
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        $("#msgChgType2").text(msg);
        $("#msgChgType3").text(msg);
        $("#msgChgType4").text(msg);
    }

    //申請人種類
    $("#napclass").on("change", function () {
        if ($("#oapclass").val() != $("#napclass").val() && $.trim($("#napclass").val()) != "") {
            reg.chgtype[0].checked = true;
        }
        else {
            reg.chgtype[0].checked = false;
        }
        reg.napcust_no.className = "";
        reg.napcust_no.readonly = false;
        switch ($("#napclass").val()) {
            case "AA":
                reg.napcust_no.className = "SEdit"
                reg.napcust_no.readonly = true
                reg.napcust_no.value = ""
                $("#nap_country").val("T");
                break;
            case "AB":
            case "AC":
            case "AD":
            case "AE":
            case "B":
                $("#nap_country").val("T");
                break;
            case "CA":
                reg.napcust_no.className = "sedit"
                reg.napcust_no.readonly = true
                $("#nap_country").val('');
                break;
            case "CB":
            case "CT":
                $("#nap_country").val('');
                break;
            default:
                break;

        }
        if ($("#napclass").val().substring(0, 1) == "B" || $("#napclass").val().substring(0, 1) == "C") {
            reg.nap_fcname.className = ""
            reg.nap_fcname.readonly = false
            reg.nap_lcname.className = ""
            reg.nap_lcname.readonly = false
            reg.nap_fename.className = ""
            reg.nap_fename.readonly = false
            reg.nap_lename.className = ""
            reg.nap_lename.readonly = false
        }
        else {
            reg.nap_fcname.className = "SEdit"
            reg.nap_fcname.readonly = true
            reg.nap_lcname.className = "SEdit"
            reg.nap_lcname.readonly = true
            reg.nap_fename.className = "SEdit"
            reg.nap_fename.readonly = true
            reg.nap_lename.className = "SEdit"
            reg.nap_lename.readonly = true
            reg.nap_fcname.value = ""
            reg.nap_lcname.value = ""
            reg.nap_fename.value = ""
            reg.nap_lename.value = ""
            reg.chgtype[4].checked = false
            reg.chgtype[6].checked = false
        }
        //if trim(reg.nap_country.value)<>empty then nap_country_onchange
        if ($.trim($("#nap_country").val())!= "") {
            nap_country_onchange();
        }

    })

    //國籍
    function nap_country_onchange() {
        if ($("#oap_country").val() != $("#nap_country").val() && $.trim($("#nap_country").val()) != "") {
            reg.chgtype[1].checked = true;
        }
        else {
            reg.chgtype[1].checked = false;
        }
        if (($("#napclass").val() == "AA" || $("#napclass").val() == "AB" || $("#napclass").val() == "AC"
               || $("#napclass").val() == "AD" || $("#napclass").val() == "AE" || $("#napclass").val() == "B")
               || ($("#napclass").val() == "" && ($("#oapclass").val() == "AA" || $("#oapclass").val() == "AB" || $("#oapclass").val() == "AC"
               || $("#oapclass").val() == "AD" || $("#oapclass").val() == "AE" || $("#oapclass").val() == "B")
              ))
            {

            if ($("#nap_country").val() != "T") {
                alert("本國公司行號及個人，不可為外國國籍!");
                $("#nap_country").val("T");
                reg.chgtype[1].checked = false;
                $("#nap_country").focus();
                return false;
            }
            
        }
        
        if (($("#napclass").val() == "CA" || $("#napclass").val() == "CB" || $("#napclass").val() == "CT")
            || ($("#napclass").val() == "" && ($("#oapclass").val() == "CA" || $("#oapclass").val() == "CB" || $("#oapclass").val() == "CT")))
        {
            if ($("#nap_country").val() == "T") {
                alert("外國人或外國公司，不可選擇中華民國國籍!");
                $("#nap_country").val("");
                reg.chgtype[1].checked = false;
                $("#nap_country").focus();
                return false;
            }
        }
    }

    //申請人編號
    function napcust_no_onblur() {
        if ($("#oapcust_no").val() != $("#napcust_no").val() && $("#napcust_no").val() != "") {
            reg.chgtype[2].checked = true;
        }
        else {
            reg.chgtype[2].checked = false;
        }
        //$("#btnsave").unlock();
        if ($("#napcust_no").val() == "") {
            return;
        }
        
        if (napcust_no_onblur3() == true) {
            $("#napcust_no").focus();
            return;
        }

        //檢查編號重複
        var b = false;
        var SQLStr = "select * from apcust a where apcust_no = '" + $("#napcust_no").val() + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) { }
                else {
                    alert("申請人編號重複，請重新輸入!");
                    b = true;
                    $("#napcust_no").focus();
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        if (b == true) { return false; }
    }

    function napcust_no_onblur2() {
        if (napcust_no_onblur3() == true) {
            $("#napcust_no").focus();
            return true;
        }

        //檢查編號重複
        var b = false;
        var SQLStr = "select * from apcust a where apcust_no = '" + $("#napcust_no").val() + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) { }
                else {
                    alert("申請人編號重複，請重新輸入!");
                    b = true;
                    $("#napcust_no").focus();
                }
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        if (b == true) { return true; }
    }

    function napcust_no_onblur3() {
        var b = false;
        var napclass = "";
        //AB、AC、AD:ID需為統一編號，B:ID需為身份証字號，CB:需為10碼，CT:需為8碼
        if ($("#napclass").val() != "") {
            napclass = $("#napclass").val();
        }
        else {
            napclass = $("#oapclass").val();
        }
        switch (napclass) {
            case "AB":
            case "AC":
            case "AD":
            case "AE":
                //if (fChkDataLen2($("#napcust_no")[0], 8, "證照編號") == "") {
                //    b = true;
                //}
                if (chkID($("#napcust_no").val(), "TaxID") == true) {
                    b = true;
                }
                break;

            case "B":
                if (chkID($("#napcust_no").val(), "ID") == true) {
                    b = true;
                }
                break;

            case "CB":
                if (fChkDataLen2($("#napcust_no")[0], 10, "證照編號") == "") {
                    b = true;
                }
                break;

            case "CT":
                if (fChkDataLen2($("#napcust_no")[0], 6, "證照編號") == "") {
                    b = true;
                }
                break;
            default:
                break;
        }
        return b;
    }


    //中文名稱
    function nap_cname1_onblur() {
        if (($.trim($("#oap_cname1").val()) != $.trim($("#nap_cname1").val()) && $.trim($("#nap_cname1").val()) != "")
           || ($.trim($("#oap_cname2").val()) != $.trim($("#nap_cname2").val()) && $.trim($("#nap_cname2").val()) != "")) {
            reg.chgtype[3].checked = true;
        }
        else {
            reg.chgtype[3].checked = false;
        }
        if ($.trim($("#nap_cname1").val()) != "") {
            if (fDataLenX($("#nap_cname1").val(), 44, "中文名稱1") == "") {
                $("#nap_cname1").focus();
            }
        }
    }
    function nap_cname2_onblur() {
        if (($.trim($("#oap_cname1").val()) != $.trim($("#nap_cname1").val()) && $.trim($("#nap_cname1").val()) != "")
          || ($.trim($("#oap_cname2").val()) != $.trim($("#nap_cname2").val()) && $.trim($("#nap_cname2").val()) != "")) {
            reg.chgtype[3].checked = true;
        }
        else {
            reg.chgtype[3].checked = false;
        }
        if ($.trim($("#nap_cname2").val()) != "") {
            if (fDataLenX($("#nap_cname2").val(), 44, "中文名稱2") == "") {
                $("#nap_cname2").focus();
            }
        }
    }
    
    $("#nap_fcname").on("blur", function () {
        if ($.trim($("#oap_fcname").val()) != $.trim($("#nap_fcname").val()) || $.trim($("#oap_lcname").val()) != $.trim($("#nap_lcname").val())) {
            reg.chgtype[4].checked = true;
        }
        else {
            reg.chgtype[4].checked = false;
        }
        if ($("#nap_fcname").val() != "") {
            if (fDataLenX($("#nap_fcname").val(), 15, "中文名稱-姓") == "") {
                $("#nap_fcname").focus();
            }
        }
    })
    $("#nap_lcname").on("blur", function () {
        if ($.trim($("#oap_fcname").val()) != $.trim($("#nap_fcname").val()) || $.trim($("#oap_lcname").val()) != $.trim($("#nap_lcname").val())) {
            reg.chgtype[4].checked = true;
        }
        else {
            reg.chgtype[4].checked = false;
        }
        if ($("#nap_lcname").val() != "") {
            if (fDataLenX($("#nap_lcname").val(), 15, "中文名稱-姓") == "") {
                $("#nap_lcname").focus();
            }
        }
    })

    //英文名稱
    $("#nap_ename1").on("blur", function () {
        if (($.trim($("#oap_ename1").val()) != $.trim($("#nap_ename1").val() && $.trim($("#nap_ename1").val())!=""))
            || ($.trim($("#oap_ename2").val()) != $.trim($("#nap_ename2").val()) && $.trim($("#nap_ename1").val()) != "")) {
            reg.chgtype[5].checked = true;
        }
        else {
            reg.chgtype[5].checked = false;
        }
        if ($("#nap_ename1").val() != "") {
            if (fDataLenX($("#nap_ename1").val(), 100, "英文名稱1") == "") {//2016/1/7由60修改為100
                $("#nap_ename1").focus();
            }
        }
    })
    $("#nap_ename2").on("blur", function () {
        if (($.trim($("#oap_ename1").val()) != $.trim($("#nap_ename1").val() && $.trim($("#nap_ename1").val()) != ""))
            || ($.trim($("#oap_ename2").val()) != $.trim($("#nap_ename2").val()) && $.trim($("#nap_ename1").val()) != "")) {
            reg.chgtype[5].checked = true;
        }
        else {
            reg.chgtype[5].checked = false;
        }
        if ($("#nap_ename2").val() != "") {
            if (fDataLenX($("#nap_ename2").val(), 100, "英文名稱2") == "") {//2016/1/7由60修改為100
                $("#nap_ename2").focus();
            }
        }
    })
    $("#nap_fename").on("blur", function () {
        if ($.trim($("#oap_fename").val()) != $.trim($("#nap_fename").val()) || $.trim($("#oap_lename").val()) != $.trim($("#nap_lename").val())) {
            reg.chgtype[6].checked = true;
        }
        else {
            reg.chgtype[6].checked = false;
        }
        if ($("#nap_fename").val() != "") {
            if (fDataLenX($("#nap_fename").val(), 30, "英文名稱-姓") == "") {
                $("#nap_fename").focus();
            }
        }
    })
    $("#nap_lename").on("blur", function () {
        if ($.trim($("#oap_fename").val()) != $.trim($("#nap_fename").val()) || $.trim($("#oap_lename").val()) != $.trim($("#nap_lename").val())) {
            reg.chgtype[6].checked = true;
        }
        else {
            reg.chgtype[6].checked = false;
        }
        if ($("#nap_lename").val() != "") {
            if (fDataLenX($("#nap_lename").val(), 30, "英文名稱-名") == "") {
                $("#nap_lename").focus();
            }
        }
    })






    
</script>
