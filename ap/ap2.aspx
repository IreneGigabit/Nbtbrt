<%@ Page Language="C#" CodePage="65001"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ap2";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtn = "";

    protected string syscode = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        //syscode = Sys.getAppSetting("Sysmenu");
        syscode = Sys.GetSession("Syscode");
        if ((Request["Syscode"] ?? "") != "") syscode = Request["Syscode"];

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryPageLayout();
            this.DataBind();
        }
    }

    private void QueryPageLayout() {
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" value=\"執行\" onclick=\"checksys()\" id=\"task1\" class=\"cbutton\">\n";
            StrFormBtn += "<input type=\"button\" value=\"重填\" id=\"task2\" class=\"cbutton\">\n";
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】<b style="color:Red">權限群組查詢引擎</b></td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="submittask" name="submittask">
    <input type="hidden" id="flag" name="flag">
    <div id="id-div-slide">
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="570" align="center">	
         <tr>
          <td align="center" class="lightbluetable">網路作業系統代碼</td>
          <td class="whitetablebg">
              <select id="Syscode" name="Syscode"></select>
          </td>
         </tr>
         <tr>    
          <td align="center" class="lightbluetable"></td>
          <td class="whitetablebg">
		    <label><input type="radio" name="show_type" value="ap">依程式設定權限</label>
  		    <select id="Apcat" name="Apcat" style="display:">
			    <option value="" style="color:blue">請選擇</option>
		    </select>
        </td>
         </tr>
          <tr>
          <td align="center" class="lightbluetable"></td>
          <td class="whitetablebg">
		    <label><input type="radio" name="show_type" value="grp">登錄群組代碼</label>
		    <select id="LoginGrp" name="LoginGrp" style="display:">
			    <option value="" style="color:blue">請選擇</option>
		    </select>
          </td>
         </tr>
         </table>
        <br>
        <center>
        <%#StrFormBtn%>
        <%#DebugStr%>
        </center>
    </div>
</form>

    <div id="tblData"></div>
</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        $("#Syscode").getOption({//網路作業系統代碼
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data:{mg:"Y",sql:"SELECT Syscode,SysnameC FROM Syscode ORDER BY Syscode"},
            valueFormat: "{Syscode}",
            textFormat: "{Syscode}({SysnameC})"
        });

        $("input.dateField").datepick();

        this_init();
    });

    function this_init(){
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $('#Syscode option').each(function () {
            $(this).val($(this).val().toUpperCase());
        });
        $("#Syscode").val("<%#syscode.ToUpper()%>").triggerHandler("change");
    }

    //執行
    function checksys(x) {
        if($("#Syscode").val()==""){
            alert("網路作業系統代碼不得為空白,請重新輸入");
            return false;
        }
        if ($("#flag").val() == "") {
            alert("請選擇種類");
            return false;
        }

        if($("#flag").val()=="1"){
            reg.action = "AP_List.aspx";

        }else if($("#flag").val()=="2"){
            reg.action = "LoginGrp_List.aspx";
        }
        reg.submit();
    }
    //[重填]
    function cleardata(){
        $("#Syscode").val("");
        $("#show_syscode,#show_menu,#show_ap,#show_ap1").hide();
        $("input[name='ap_type']").prop("checked", false);
    }

    //////////////////////
    //依系統代碼帶Apcat/LoginGrp
    $("#Syscode").change(function () {
        $("#Apcat").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data:{mg:"Y",sql:"select APcatID,APcatCName from apcat where SYScode = '" + $("#Syscode").val() + "' order by APcatID"},
            valueFormat: "{APcatID}",
            textFormat: "{APcatID}_{APcatCName}"
        });
        $("#LoginGrp").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data: { mg: "Y", sql: "select LoginGrp,GrpName from logingrp where SYScode = '" + $("#Syscode").val() + "' order by LoginGrp" },
            valueFormat: "{LoginGrp}",
            textFormat: "{LoginGrp}_{GrpName}"
        });
    });

    //點選作業項目
    $("input[name='show_type']").click(function () {
        //$("#Apcat,#LoginGrp").hide();
        $("#flag").val("");
        if ($("#Syscode").val() == "") {
            alert("網路作業系統代碼不得為空白,請重新輸入");
            $("input[name='show_type']").prop("checked", false);
            return false;
        }

        if ($(this).val() == "ap") {//依程式
            $("#Apcat").show();
            $("#flag").val("1");
        } else if ($(this).val() == "grp") {//依登錄群組
            $("#LoginGrp").show();
            $("#flag").val("2");
        }
    });

</script>
