<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "交辦專案室爭救案品質評分表";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt43";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string html_pr_scode = "";

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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

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
        //承辦人
        DataTable dtPrScode = Sys.GetGrpidScode("B", "T100", "");
        html_pr_scode = dtPrScode.Option("{scode}", "{scode}--{sc_name}", false);
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <div id="id-div-slide">
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="75%" align="center">	
 	        <tr>
		        <td class="lightbluetable" align="right">報表種類 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
			        <label><input type="radio" value="1" name=qryprint>統計表</label>
			        <label><input type="radio" value="2" name=qryprint>明細表</label>
		        </td> 
	        </tr>
	        <tr id="tr_qryinclude" style="display:none">
		        <td class="lightbluetable" align="right">包含項目 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
			        <input type="radio" value="N" name=qryinclude checked>不含附屬案性
			        <input type="radio" value="Y" name=qryinclude>只印附屬案性
			        <input type="radio" value="" name=qryinclude>全部
		        </td> 
	        </tr>
            <tr >
	            <td class=lightbluetable align=right nowrap>區所：</td>
	            <td class=whitetablebg colspan=3> 
			        <label><input type="radio" value="N" name=qryBranch>台北</label>
			        <label><input type="radio" value="C" name=qryBranch>台中</label>
			        <label><input type="radio" value="S" name=qryBranch>台南</label>
			        <label><input type="radio" value="K" name=qryBranch>高雄</label>
			        <label><input type="radio" value="" name=qryBranch checked>全部</label>
               </td>
            </tr>  
	        <tr id="tr_Bseq">
		        <td class="lightbluetable" align="right">區所編號 :</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="qryBseq" name="qryBseq" size="5" maxLength="5">-<input type="text" id="qryBseq1" name="qryBseq1" size="1" maxLength="1">
		        </td> 
		        <td class="lightbluetable" align="right">客戶編號 :</td>
		        <td class="whitetablebg" align="left">
			        <input type="text" id="qrycust_seq" name="qrycust_seq" size="5">
		        </td> 
	        </tr>
            <tr id="tr_qryscode">
		        <td class="lightbluetable" align="right">營洽 :</td>
		        <td class="whitetablebg" align="left">
			        <span id="span_scode">
				        <Select id="qryin_scode" name="qryin_scode"></Select>
			        </span>	
		        </td>
		        <td class="lightbluetable" align="right">承辦人 :</td>
		        <td class="whitetablebg" align="left">
	                <select id="qryPR_SCODE" name="qryPR_SCODE">
                        <option value="" style="color:blue">全部</option>
                        <%#html_pr_scode%>
	                </select>
		        </td> 
	        </tr>	
	        <tr id="tr_month">
		        <td class="lightbluetable" align="right">判行日期 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
			        年度：
				        <select id="qryYear" name="qryYear"></select><br>
			        月份：
				        <input type="text" id="qrysMonth" name="qrysMonth" size="2" maxlength="2" value="1">月～
				        <input type="text" id="qryeMonth" name="qryeMonth" size="2" maxlength="2">月
		        </td>
	        </tr>
	        <tr id="tr_date">
		        <td class="lightbluetable" align="right">判行日期 :</td>
		        <td class="whitetablebg" align="left" colspan="3">
		            <input type="text" id="qrysDATE" name="qrysDATE" size="10" maxLength="10" class="dateField">～
		            <input type="text" id="qryeDATE" name="qryeDATE" size="10" maxLength="10" class="dateField">
		        </td> 
	        </tr>
        </table>
        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
			    <input type="button" value="查　詢" class="cbutton" id="btnSrch" name="btnSrch">
			    <input type="button" value="重　填" class="cbutton" id="btnRest" name="btnRest">
	        </td></tr>
        </table>
    </div>
</form>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        //年度
        var qryYear="";
        for(var j = 2000; j<=2060;j++){
            qryYear+='<option value="' + j + '">' + j + '</option>'
        }
        $("#qryYear").replaceWith('<select id="qryYear" name="qryYear">' + qryYear + '</select>');

        $("input.dateField").datepick();

        $("#tabBtn").showFor((<%#HTProgRight%> & 2)).find("input").prop("checked",true);//[查詢][重填]

        this_init();
    });

    function this_init(){
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input[name='qryprint']").eq(0).prop("checked",true).triggerHandler("click");

        $("input[name='qryBranch']").prop("disabled",true);
        $("input[name='qryBranch'][value='<%=Session["seBranch"]%>']").prop("disabled",false).prop("checked",true);
        $("input[name='qryBranch']:checked").triggerHandler("click");

        $("#qryYear").val((new Date()).format("yyyy"));
        $("#qryeMonth").val((new Date()).format("M"));
    }

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
    });
    //////////////////////
    //報表種類
    $("input[name='qryprint']").click(function () {
        if($(this).val()=="1"){
            $("#tr_Bseq,#tr_qryscode,#tr_date").hide();
            $("#tr_month").show();
        }else if($(this).val()=="2"){
            $("input[name='qSTAT_CODE']").prop("disabled",false);
            $("#tr_Bseq,#tr_qryscode,#tr_date").show();
            $("#tr_month").hide();
            $("input[name='qryBranch']:checked").triggerHandler("click");
        }
    });

    //區所
    $("input[name='qryBranch']").click(function () {
        var tbranch=$(this).val();
        $("#qryin_scode").getOption({//營洽
            url: getRootPath() + "/ajax/json_get_scode.aspx?branch="+tbranch,
            valueFormat: "{in_scode}",
            textFormat: "{in_scode}_{scode_name}",
            showEmpty:false,
            firstOpt: "<option value='' style='color:blue'>全部</option>"
        });

        if ((main.right & 64) == 0) {
            $('#qryin_scode')
            .empty()
            .append('<option selected="selected" value="<%=Session["scode"]%>"><%=Session["scode"]%>_<%=Session["sc_name"]%></option>');
        }
    });

    $("#qrysMonth,#qryeMonth").blur(function (e) {
        if (chkNum1($(this)[0], "月份")) return false;
        if(parseInt($("#qrysMonth").val())<1||parseInt($("#qrysMonth").val())>12){
            alert("月份請輸入介於1~12的數字!");
            $(this).focus();
            return false;
        }
    });

    //[查詢]
    $("#btnSrch").click(function (e) {
        if ($("input[name='qryprint']:checked").val()=="1"){
            reg.action = "<%=HTProgPrefix%>_list1.aspx";
        }else if($("input[name='qryprint']:checked").val()=="2"){
            reg.action = "<%=HTProgPrefix%>_list2.aspx";
        }
        //reg.target = "Eblank";
        reg.submit();
    });
</script>
