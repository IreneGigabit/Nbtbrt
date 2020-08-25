<%@ Page Language="C#" CodePage="65001"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ap1";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string syscode = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        syscode = Sys.getAppSetting("Sysmenu");
        //syscode = Sys.GetSession("Syscode");
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
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】<b style="color:Red">系統群組查詢引擎</b></td>
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

    <div id="id-div-slide">
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="570" align="center">	
         <tr>
          <td align="center" class="lightbluetable">網路作業系統代碼</td>
          <td class="whitetablebg">
              <select id="Syscode" name="Syscode"></select>
          </td>
         </tr>
         <tr>    
          <td align="center" class="lightbluetable">作業項目</td>     
          <td class="whitetablebg">
		    <label><input type="radio" name="ap_type" value="syscode">系統代碼作業</label>
		    <label><input type="radio" name="ap_type" value="menu">Menu作業</label>
		    <label><input type="radio" name="ap_type" value="ap">程式代碼作業</label>
          </td>     
         </tr>
         <tr id="show_ap1" style="display:none">
		    <td align="center" class="lightbluetable">Menu作業分類代碼</td>
		    <td class="whitetablebg">
		    <select id="Apcat" name="Apcat">
			    <option value="" style="color:blue">請選擇</option>      
		    </select>
		    </td>
         </tr>
         </table>

        <br>
        <%#DebugStr%>
        <center>
        <div id="show_syscode" style="display:none">
		    <input type="button" name="syscode1" value="新增系統代碼" onclick="addsys1('A')" class="cbutton">
		    <input type="button" name="syscode2" value="查詢系統代碼" onclick="addsys1('Q')" class="cbutton">
		    <input type="button" name="syscode3" value="重　填" onclick="cleardata()" class="cbutton">
	    </div>
        <div id="show_menu" style="display:none">
		    <input type="button" name="menu2" value="新增Menu作業" onclick="menu_control('A')" class="cbutton">
		    <input type="button" name="menu1" value="查詢Menu作業" onclick="menu_control('Q')" class="cbutton">
		    <input type="button" name="menu3" value="重　填" onclick="cleardata()" class="cbutton">
        </div>
        <div id="show_ap" style="display:none">
		    <input type="button" name="ap2" value="新增程式代碼" onclick="ap_control('A')" class="cbutton">
		    <input type="button" name="ap1" value="查詢程式代碼" onclick="ap_control('Q')" class="cbutton">
		    <input type="button" name="ap3" value="重　填" onclick="cleardata()" class="cbutton">
        </div>
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

    function addsys1(x){//系統代碼作業
        $("#submittask").val(x);
        if (x == "A") {
            reg.action = "Syscode_Edit.aspx";
            reg.target = "Eblank";
            reg.submit();
        } else if (x == "Q") {
            reg.action ="Syscode_List.aspx";
            reg.target = "_self";
            reg.submit();
        }
    }

    function menu_control(x){//menu維護作業
        $("#submittask").val(x);
        if(x=="A"){
            reg.action = "APCat_Edit.aspx";
            reg.target = "Eblank";
            reg.submit();
        }else if(x=="Q"){
            reg.action = "APCat_List.aspx";
            reg.target = "_self";
            reg.submit();
        }
    }

    function ap_control(x){//程式代碼維護作業
        $("#submittask").val(x);
        if (x == "A") {
            reg.action = "AP_Edit.aspx";
            reg.target = "Eblank";
            reg.submit();
        }else if(x=="Q"){
            reg.action = "AP_List.aspx";
            reg.target = "_self";
            reg.submit();
        }
    }

    //[重填]
    function cleardata(){
        $("#Syscode").val("");
        $("#show_syscode,#show_menu,#show_ap,#show_ap1").hide();
        $("input[name='ap_type']").prop("checked", false);
    }

    //////////////////////
    //依系統代碼帶Menu作業分類代碼
    $("#Syscode").change(function () {
        $("#Apcat").getOption({//Menu作業分類代碼
            url: getRootPath() + "/ajax/JsonGetSqlDataCnn.aspx",
            data:{mg:"Y",sql:"select APcatID,APcatCName from apcat where SYScode = '" + $("#Syscode").val() + "' order by APcatID"},
            valueFormat: "{APcatID}",
            textFormat: "{APcatID}_{APcatCName}"
        });
    });

    //點選作業項目
    $("input[name='ap_type']").click(function () {
        $("#show_syscode,#show_menu,#show_ap,#show_ap1").hide();

        if ($(this).val() == "syscode") {
            $("#show_syscode").show();
        } else if ($(this).val() == "menu") {
            if ($("#Syscode").val() == "") {
                alert("網路作業系統代碼不得為空白,請重新輸入");
                $("input[name='ap_type']").prop("checked", false);
                return false;
            }
            $("#show_menu").show();
        } else if ($(this).val() == "ap") {
            if ($("#Syscode").val() == "") {
                alert("網路作業系統代碼不得為空白,請重新輸入");
                $("input[name='ap_type']").prop("checked", false);
                return false;
            }
            $("#show_ap,#show_ap1").show();
        }
    });

</script>
