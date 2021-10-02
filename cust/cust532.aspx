<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = " 標籤列印作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust532";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = "cust532";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string deptName = "";
    protected string cust_area = "";

    protected string printType = "";
    protected string ap_cname = "";

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

        deptName = (Sys.GetSession("dept") == "P") ? "專利" : "商標";
        cust_area = Sys.GetSession("seBranch");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {

            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a href=http://web02/BRP/cust/客戶報表操作手冊.files/frame.htm target=_blank>[補助說明]</a>";
        }
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form name="reg" method="post" id="reg" action>
<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>" />
<input type="hidden" name="pType" id="pType" value="" />
<input type=hidden name="arrayList" id="arrayList">
<input type=hidden name="saveType" id="saveType">
<input type=hidden name="actionflag">
<center>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="60%">
	<TR>
		<TD class=lightbluetable align=right>列印種類：</TD>
		<TD class=whitetablebg>
		<INPUT type=radio name="printtype" onclick="printtype_onclick()" value="A" checked>聯絡人
		<INPUT type=radio name="printtype" onclick="printtype_onclick()" value="B" >代表人
		</TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>列印份數：</TD>
		<TD class=whitetablebg>
		<input type=text name=print_num value="1" size="4" maxlength="3">
		</TD>
	</tr>
</table>
<br />
<table width="50%" cellspacing="1" cellpadding="0" class="bg" border=0>
	<tr align="left">
		<td align="center" class="lightbluetable" width=20%>客戶編號</td>
		<td align="center" class="lightbluetable"><span id="TypeName">聯絡人/代表人</span></td>
        <td align="center" class="lightbluetable"></td>
	</tr>
	<tr align=center>
		<td class="whitetablebg">
			<input type=text name="cust_seq" id="cust_seq" size="10" onblur="cust_seq_onblur()" value="">
		</td>
		<td class="whitetablebg">
			<div id="divap_cnameA">
				<select name="cmbap_cname" id="cmbap_cname" size="1" >
					<option style="color:blue" value ="X">請輸入客戶編號</option>
				</select>
			</div>
			<div id="divap_cnameB">
				<input type=text name="txtap_cname" id="txtap_cname" readonly class=SEdit value=<%=ap_cname%>>
			</div>
		</td>
		<td align="center" width=10%>
			<input type=button value ="加入列印名單" class="cbutton"  onClick="AddSubmit()" name=button3>
		</td>
	</tr>
</TABLE>
<hr width=60% align=center><br>
<table  width="50%" cellspacing="0" cellpadding="1" class="bg" border=1>
	<tr><td class="lightbluetable" align=center ><span id="ListName">聯絡人/代表人</span>列印名單</td></tr>
	<tr>
		<td align=center class="whitetablebg"><br>
			<select name="printList" id="printList" multiple="multiple" size=10>
			</select>
			<br><Br>
			<input type=button value ="從列印名單中移除" class="cbutton" style="cursor:hand" onClick="DelListItem()">
			<input type=button value ="列印名單-清檔" class="redbutton" style="cursor:hand" onClick="ClearData()">
			<br><br>
		</td>
	</tr>
</TABLE>	

</center>
     <%#DebugStr%>
</form>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr><td width="100%">     
		<p align="center">
		<input type="button" value="列印名單-存檔" class="cbutton" style="cursor:hand" id="btnSave" name="btnSave">
		<input type="button" value="列印名單-產生Word" class="cbutton" style="cursor:hand" id="btnPrint" name="btnPrint">
	</td></tr>
</table>
<br>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
<div id="dialog"></div>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";

            printtype_onclick();
            $("#saveType").val("");
        }
    }

    function LoadDefaultList(ptype) {
        $("#printList option").each(function () {
            $(this).remove();
        });

        var SQLStr = "select * from cust532 where scode = '<%=Sys.GetSession("scode")%>'  and ptype = '" + ptype + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {

                    $.each(JSONdata, function (i, item) {
                        var s = "";
                        s = "<option value='" + item.cust_seq + "|" + item.att_sql+"'>" + item.cust_seq + "_" + item.ap_cname1;
                        if (ptype == "A") {
                            s += "_" + item.att_sql
                        }
                        s += "_" + item.name + " </option>";
                        $("#printList").append(s);

                    })
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


    function printtype_onclick() {
        $("input[name=printtype]").each(function () {
            if ($(this).prop("checked") == true) {
                $("#pType").val($(this).val());
            }
        })
        $("#cust_seq").val("");
        LoadDefaultList($("#pType").val());//讀取列印名單From cust532
        if ($("#pType").val() == "A")//聯絡人
        {
            //$("#cmbap_cname option").each(function () {
            //    $(this).remove();
            //});
            $("#cmbap_cname").empty();
            $("#cmbap_cname").append("<option value='' style = 'color:blue'>請輸入客戶編號</option>")
            $("#ListName").text("聯絡人");
            $("#TypeName").text("聯絡人");
            $("#divap_cnameB").hide();
            $("#divap_cnameA").show();
        }
        else//代表人
        {
            $("#txtap_cname").val("");
            $("#divap_cnameA").hide();
            $("#divap_cnameB").show();
            $("#ListName").text("代表人");
            $("#TypeName").text("代表人");
        }
    }


    function cust_seq_onblur() {
        if ($("#cust_seq").val() != "") {
            if ($("#pType").val() == "A") {
                LoadData_att(2);
            }
            else {
                LoadData_ref_seq(2);
            }
        }
    }

    function LoadData_att(n) {

        var Str1 = "";
        var Str3 = "";
        var SQLStr = "";
        switch (n)
        {
            case 1:
                SQLStr = "select attention from custz_att where cust_area='<%=Sys.GetSession("seBranch")%>' and cust_seq=" + $("#cust_seq").val() + " and att_sql= " + $("#cmbap_cname").val();
                break;

            case 2:
                SQLStr = "select att_sql,attention,dept,att_code from custz_att where cust_area='<%=Sys.GetSession("seBranch")%>'" + " and cust_seq= " + $("#cust_seq").val() + " and att_code in ('NN','NU','')";
                break;

            case 3:
                SQLStr = "select ap_crep from apcust where cust_area='<%=Sys.GetSession("seBranch")%>' and cust_seq=" + $("#cust_seq").val();
                break;

            default:
                break;
        }

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {

                    if (n == 1) {
                        Str1 = JSONdata[0].attention;
                    }

                    if (n == 2) {//聯絡人選單-清除重放
                        $("#cmbap_cname option").each(function () {
                            $(this).remove();
                        });
                        $("#cmbap_cname").append("<option value='' style = 'color:blue'>請選擇</option>");
                        $.each(JSONdata, function (i, item) {
                            $("#cmbap_cname").append('<option value=' + item.att_sql + '>' + item.dept + "_" + item.attention + '</option>');
                        })
                    }

                    if (n == 3) {
                        Str3 = JSONdata[0].ap_crep;
                    }
                    
                }
                else {
                    alert("客戶編號不存在，請重新輸入!");
                    $("#cust_seq").focus();
                    return;
                }

            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });

        //將值傳回AddToList()
        if (n == 1) { return Str1; }
        if (n == 3) { return Str3; }
    }//loadData End

    function LoadData_ref_seq(i) {

        var setListName = "";
        var SQLStr = "select ap_cname1,ap_cname2 from apcust where cust_seq= " + $("#cust_seq").val();
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    var item = JSONdata[0];
                    if (i == 1) {
                        setListName = item.ap_cname1 + item.ap_cname2;
                    }
                    else {
                        $("#txtap_cname").val(item.ap_cname1 + item.ap_cname2);
                    }
                }
                else {
                    alert("客戶編號不存在，請重新輸入!");
                    $("#txtap_cname").val("");
                    $("#cust_seq").focus();
                    return;
                }

            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        if (i == 1) {return setListName;}
    }//loadData End

    function AddSubmit() {
        if ($.trim($("#cust_seq").val()) == "") {
            alert("請輸入客戶編號!"); return;
        }

        if ($("#pType").val() == "A") {
            if ($("#cmbap_cname").val() == "") {
                alert("請點選聯絡人!"); return;
            }
        }
        else {}


        var tmpstr;
        var chkdouble = false;
        if ($("#pType").val() == "A") {
            tmpstr = $("#cust_seq").val() + "|" + $("#cmbap_cname").val();
        }
        else {
            tmpstr = $("#cust_seq").val() + "|0";
        }
        $("#printList option").each(function () {
            if (tmpstr == $(this).val()) {
                chkdouble = true;
                alert("該筆資料已經存在於列印名單之列!!");
                return false;
            }
        })
        if (chkdouble == false) { AddToList(); }
    }

    function AddToList() {

        if ($("#pType").val() == "A") {

            $('#printList').append($('<option>', {
                value: $("#cust_seq").val() + "|" + $("#cmbap_cname").val(),
                text: $("#cust_seq").val() + "_" + LoadData_ref_seq(1) + "_" + $("#cmbap_cname").val() + "_" + LoadData_att(1)
            }));
        }
        else {

            $('#printList').append($('<option>', {
                value: $("#cust_seq").val() + "|0",
                text: $("#cust_seq").val() + "_" + $("#txtap_cname").val() + "_" + LoadData_att(3)
            }));
        }
    }

    function DelListItem() {
        var len = $('#printList > option').length - 1;
        for (var i = len; i >= 0; i--) {
            if ($('#printList > option')[i].selected == true) {
                var s = $('#printList > option')[i].value;
                $('#printList option[value="'+ s +'"]').remove()
            }
        }
    }
    

    //[Print Word & Save]
    $("#btnPrint").click(function (e) {
        if ($('#printList > option').length == 0) {
            alert("請輸入客戶編號!!!");
            $("#cust_seq").focus();
            return;
        }

        $("#btnSave").click();

        setTimeout(function () {
            reg.action = "cust532_word.aspx?prgid=<%=prgid%>";
            reg.submit();
        }
            , 500
        );
    });

    //[存檔]
    $("#btnSave").click(function (e) {

        var ar = new Array();
        for (var i = 0; i < $('#printList > option').length; i++) {
            ar += $('#printList  option')[i].value + ",";
        }
        $("#arrayList").val(ar);
        $("#saveType").val("");
        goSave();
    });

    function goSave() {
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust532_Update.aspx", formData)
        .complete(function (xhr, status) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息', modal: true, maxHeight: 500, width: 800, closeOnEscape: false
                , buttons: {
                    確定: function () {
                        $(this).dialog("close");
                    }
                }

                , close: function (event, ui) {
                    if (status == "success") {
                        //if(!$("#chkTest").prop("checked")){
                        //}
                    }
                }
            });
        });
    }

    function ClearData() {
        var msgstr;
        if ($("#pType").val() == "A") {
            msgstr = "確定清除「聯絡人標籤檔」所有資料 ?";
        }
        else {
            msgstr = "確定清除「代表人標籤檔」所有資料 ?";
        }
        if (confirm(msgstr)) {
            //Delete all items
            $("#printList").empty();
            $("#saveType").val("Clear");
            goSave();
        }
    }





     
</script>
