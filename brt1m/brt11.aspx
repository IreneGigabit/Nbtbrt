<%@ Page Language="C#" CodePage="65001"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "";//"國內案接洽暨交辦作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
  
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }
    
    private void PageLayout() {
        StrFormBtnTop += "<a href=\""+Page.ResolveUrl("~/cust/cust11_1.aspx")+"?gs_dept="+Session["Dept"]+"\">[客戶查詢]</a>\n";
        StrFormBtnTop += "<a href=\""+Page.ResolveUrl("~/cust/cust11.aspx")+"?gs_dept="+Session["Dept"]+"\">[客戶新增]</a>\n";
        
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" name=end_date id=end_date>
    <input type="hidden" name=country id=country>
    <input type="hidden" name=ext_seq id=ext_seq>
    <input type="hidden" name=ext_seq1 id=ext_seq1>
    <INPUT type="hidden" name="type" id="type" value="Brt">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="70%" align="center">	
            <thead>
	            <TR>
		            <TD class=lightbluetable align=right width=40%>作業種類 :</TD>
		            <TD class=whitetablebg align=left>
                        <label><INPUT type=radio name="kind" value="new">新客戶</label>
					    <label><INPUT type=radio name="kind" value="pass">舊客戶</label>
					    <label><INPUT type=radio name="kind" value="old">舊案</label>
				    </TD>
	            </TR>
            </thead>
            <tbody>
	            <TR class="showcust">
		            <TD class=lightbluetable align=right width=40%>客戶編號 :</TD>
		            <TD class=whitetablebg align=left>
                        <INPUT type=text id="tfx_Cust_area" name="tfx_Cust_area" readonly class="SEdit" size="1">-<INPUT type="text" id="tfx_Cust_seq" name="tfx_Cust_seq" size="10">
		            </TD>
	            </TR>
	            <TR class="showcust">	
		            <TD class=lightbluetable align=right>客戶名稱 :</TD>
		            <TD class=whitetablebg align=left>
                        <INPUT type=text id="pfx_Cust_name" name="pfx_Cust_name" size="10">
		            </TD>
	            </TR>
                <TR class="showcustseq">
		            <TD class=lightbluetable align=right width=40%>本所編號 :</TD>
		            <TD class=whitetablebg align=left>
                        <INPUT type=text id="tfx_seq" name="tfx_seq" size="5" maxlength="5">-<INPUT type="text" id="tfx_seq1" name="tfx_seq1" size="1" maxlength="1" value="_">
		            </TD>
	            </TR>
            </tbody>
        </table>
        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <%#StrFormBtn%>
	        </td></tr>
        </table>
    </div>
</form>

<div id="dialog">
    <!--iframe id="myIframe" src="about:blank" width="100%" height="97%" style="border:none""></iframe-->
</div>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("#tfx_Cust_area").val("<%#Session["sebranch"]%>");
        $("#qryForm tbody tr").hide();
    }

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name='kind']:checked").length == 0) {
            alert("請選擇作業種類!");
            return false;
        }
        var doSubmit = true;
        if ($("input[name='kind']:checked").val() == "pass") {
            if ($("#tfx_Cust_seq").val() == "" && $("#pfx_Cust_name").val() == "") {
                alert("請輸入客戶編號或客戶名稱!");
                return false;
            }
            $("#tfx_seq").val("");
        }

        if ($("input[name='kind']:checked").val() == "old") {
            if ($("#tfx_seq").val() == "") {
                alert("請輸入本所編號!");
                return false;
            } else {
                doSubmit = chkseq();
            }
        }

        if (doSubmit) {
            reg.action = "<%=HTProgPrefix%>Listinfo.aspx";
            //reg.target = "Eblank";
            reg.submit();
        }
    });

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //////////////////////
    //作業種類
    $("input[name='kind']").click(function () {
        $("#qryForm tbody tr").hide();
        if ($(this).val() == "new") {//新客戶
            window.location.href = "../cust/cust11.aspx?gs_dept=t&prgid=Brt11&modify=A";
        } else if ($(this).val() == "pass") {//舊客戶
            $(".showcust").show();
        } else if ($(this).val() == "old") {//舊案
            $(".showcustseq").show();
            $("#tfx_seq1").val("_");
        }
    });

    function chkseq() {
        var rtnFlag = true;
        var searchSql = "select 'T' as country,end_date,0 as ext_seq,'' as ext_seq1 from dmt where seq='" + $("#tfx_seq").val() + "' and seq1='" + $("#tfx_seq1").val() + "' ";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    rtnFlag = false;
                    alert("查無此案件編號!!");
                    $("#end_date").val("");
                    $("#country").val("");
                    $("#ext_seq").val("");
                    $("#ext_seq1").val("");
                } else {
                    $("#end_date").val(dateReviver(JSONdata[0].end_date, "yyyy/M/d"));
                    $("#country").val(JSONdata[0].country);
                    $("#ext_seq").val(JSONdata[0].ext_seq);
                    $("#ext_seq1").val(JSONdata[0].ext_seq1);
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>查詢案件編號載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '查詢案件編號載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        return rtnFlag;
    }
</script>
