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
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE html>

<script runat="server">

    protected string HTProgCap = "申請人相關資料維護";
    private string HTProgCode = "cust13";
    protected string HTProgPrefix = "cust13";
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string StrAddLink = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    protected string submitTask = "";
    protected string apsqlno = "";
    protected string apcust_no = "";
    protected string ap_sql = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string StrSETCustSeq = "";
    protected string prgid = HttpContext.Current.Request["prgid"];
    protected string hrefq = "";
    protected string scode = "";
    //申請人種類
    protected string html_apclass = Sys.getCustCode("apclass", "", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //申請人國籍
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e)
    {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        //scode = Session["scode"].ToString();
        apsqlno = Request["apsqlno"];
        apcust_no = Request["apcust_no"];
        ap_sql = Request["ap_sql"];
        
        submitTask = Request["submitTask"];
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";

        //if (submitTask == "A") { }
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        string SQLStr = "select apsqlno, apcust_no, cust_area, cust_seq from apcust where apsqlno = '" + apsqlno + "' AND apcust_no = '" + apcust_no + "'";
        SqlDataReader dr = conn.ExecuteReader(SQLStr);
        if (dr.Read())
        {
            StrSETCustSeq = "<font color=blue>客戶編號：" + dr["cust_area"].ToString() + "-" + dr["cust_seq"].ToString() + "</font>";
        }
        dr.Close(); dr.Dispose();
        conn.Dispose();
        //Sys.showLog(SQLStr);
        //Response.Write("HTProgCode:" + HTProgCode + "<br>");
        //Response.Write("HTProgAcs:" + HTProgAcs + "<br>");
        //Response.Write("HTProgRight : " + HTProgRight);
        //Response.Write("SubmitTask : " + submitTask + "<br>");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();

        if (HTProgRight >= 0)
        {
            QueryPageLayout();
            this.DataBind();
        }
    }
    
    private void QueryPageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
            //StrFormBtnTop += "<a href=javascript:window.history.go(-1)>[回上頁]</a>";
        }
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=javascript:GoToSearch()>[申請人查詢]</a>";
        }
        
        if (((HTProgRight & 4) > 0 && (submitTask == "A")) || ((HTProgRight & 8) > 0 && (submitTask == "U")) || 
            ((HTProgRight & 8) > 0 && (submitTask == "A" || submitTask == "U" || submitTask == "C")) || (HTProgRight & 256) > 0)
        {
            if (submitTask == "Q") { }
            else
            {
                StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton\"  />";
                StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";    
            }
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
    <input type="hidden" id="HTProgPrefix" name="HTProgPrefix" value="<%=HTProgPrefix%>" />
    <input type="hidden" id="HTProgCode" name="HTProgCode" value="<%=HTProgCode%>" />
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>" />
    <input type="hidden" id="submitTask" name="submitTask" value="<%=submitTask%>" />
    <input type="hidden" id="apsqlno" name="apsqlno" value="<%=apsqlno%>" />
    <table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】
            <%#StrSETCustSeq %>
        </td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
    </table>

    <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" >
	<tr>
		<td class="lightbluetable" align="right">※申請人種類：</td>
		<td class="whitetablebg" align="left">
            <input name="hapclass" id="hapclass" type="hidden" value="" />
				<select name="apclass" id="apclass" value="" onchange="apclass_onchange()">
                    <%#html_apclass%>
				</select>
		</td>
		<td class="lightbluetable" align="right" width="12%">申請人國籍：</td>
		<td class="whitetablebg" align="left">
			<select name="ap_country" id="ap_country">
                <%#html_country%>
			</select> 
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" width="17%">※申請人編號：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="text" id="apcust_no" NAME="apcust_no" SIZE="11" MAXLENGTH="10" readonly >
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">※申請人名稱(中)：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="text" NAME="ap_cname1" id="ap_cname1" SIZE="47" MAXLENGTH="44" readonly  value="">
			<input TYPE="text" NAME="ap_cname2" id="ap_cname2" SIZE="47" MAXLENGTH="44" readonly  value="">
		</td>
	</tr>
    <tr>
        <td class="lightbluetable" align="right">序號：</td>
        <td class="whitetablebg" colspan="3">
            <input TYPE="text" NAME="ap_sql" id="ap_sql" SIZE="47" MAXLENGTH="44" readonly value="">
        </td>
    </tr>
	<tr>
		<td class="lightbluetable" align="right">申請人名稱(英)：</td>
		<td class="whitetablebg" colspan="3">
			<input TYPE="text" NAME="ap_ename1" id="ap_ename1" SIZE="60" MAXLENGTH="100" value="">
			<input TYPE="text" NAME="ap_ename2" id="ap_ename2" SIZE="60" MAXLENGTH="100" value="">
		</td>
	</tr>
	<tr><!--2016/1/7增加地址長度120-->	
		<td class="lightbluetable" align="right">證照地址(中)：</td>
		<td class="whitetablebg" colspan="3">
		郵遞區號 <input TYPE="text" NAME="ap_zip" id="ap_zip" SIZE="8" MAXLENGTH="8" value="" style="margin-bottom:4px;" onkeyup="value=value.replace(/[^\d]/g,'') "/><br />
		<input TYPE="text" NAME="ap_addr1" id="ap_addr1" SIZE="103" MAXLENGTH="120" value="" style="margin-bottom:4px;"/><br />
		<input TYPE="text" NAME="ap_addr2" id="ap_addr2" SIZE="103" MAXLENGTH="120" value=""/></td>
	</tr>
	<tr><!--2016/1/7增加地址長度120-->	
		<td class="lightbluetable" align="right">證照地址(英)：</td>
		<td class="whitetablebg" colspan="3">
        <input type="text" name="ap_eaddr1" id="ap_eaddr1" size="103" maxlength="120" style="margin-bottom:4px;" /><br />
        <input type="text" name="ap_eaddr2" id="ap_eaddr2" size="103" maxlength="120" style="margin-bottom:4px;" /><br />
        <input type="text" name="ap_eaddr3" id="ap_eaddr3" size="103" maxlength="120" style="margin-bottom:4px;" /><br />
        <input type="text" name="ap_eaddr4" id="ap_eaddr4" size="103" maxlength="120" />
		</td>
	</tr>
    <tr>
		<td class="lightbluetable" align="right">備註說明：</td>
		<td class="whitetablebg" colspan="3"><textarea name="ap_remark" id="ap_remark" cols="102" rows="5"  ></textarea></td>
	</tr>	
</table>
    
    </div>
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
        loadData();
        SetReadOnly();
        if ($("#submitTask").val() == "Q") {

            $("input[type=text]").each(function () {
                $(this).lock();
            });

            $("#ap_remark").lock();
        }

    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            //window.parent.tt.rows = "100%,0%";
            window.parent.tt.rows = "0%,100%";
        }
        $("input.dateField").datepick();
        //$("#cust_area").val("<%=Session["seBranch"]%>");
    }

    function SetReadOnly() {
        $("#apclass").lock();
        $("#ap_country").lock();
        $("#apcust_no").lock();
        $("#ap_cname1").lock();
        $("#ap_cname2").lock();
        $("#ap_sql").lock();
    }

    function GoToSearch() {
        reg.action = "cust13_1.aspx?prgid=cust13_1&submitTask=<%#(submitTask == "Q") ? "Q" : "U"%>";
        reg.submit();
    }

    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
    });

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });

    //[查詢]
    $("#btnSave").click(function (e) {

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust13_2Update.aspx",formData)
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
                        if (!$("#chkTest").prop("checked")) {
                            window.parent.tt.rows = "100%,0%";
                            window.parent.Etop.goSearch();//重新整理
                        }
                    }
                }
            });
        });


        //reg.action = "cust13_2Update.aspx";
        //reg.submit();
    });

    function loadData() {
        var psql;
        var Type = "";
        Type = "<%#submitTask%>";
        if (Type == "A") {
            psql = "select apclass, ap_country, apcust_no, ap_cname1, ap_cname2 from apcust where apsqlno = '<%=apsqlno%>'";
        }
        else {
            psql = "select a.*, b.apclass, b.ap_country, b.apcust_no, b.ap_cname1, b.ap_cname2 ";
            psql += "from ap_nameaddr a LEFT JOIN apcust b ON a.apsqlno = b.apsqlno ";
            psql += "where a.apsqlno = '<%=apsqlno%>' and ap_sql = '<%=ap_sql%>'";
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
                //$.each(JSONdata, function (i, item) {
                    $("#apclass").val(item.apclass);
                    $("#apcust_no").val(item.apcust_no);
                    $("#ap_country").val(item.ap_country);
                    $("#ap_cname1").val(item.ap_cname1);
                    $("#ap_cname2").val(item.ap_cname2);
                    
                    $("#ap_sql").val(item.ap_sql);
                    $("#ap_ename1").val(item.ap_ename1);
                    $("#ap_ename2").val(item.ap_ename2);
                    $("#ap_zip").val(item.ap_zip);
                    $("#ap_addr1").val(item.ap_addr1);
                    $("#ap_addr2").val(item.ap_addr2);
                    $("#ap_eaddr1").val(item.ap_eaddr1);
                    $("#ap_eaddr2").val(item.ap_eaddr2);
                    $("#ap_eaddr3").val(item.ap_eaddr3);
                    $("#ap_eaddr4").val(item.ap_eaddr4);
                    $("#ap_remark").val(item.ap_remark);
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }



</script>
