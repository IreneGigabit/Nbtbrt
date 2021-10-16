<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "一般請款單開立作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "ext71";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    protected string qs_dept = "", tblname = "", td_tscode = "";
    protected string apcust_no = "", ap_cname = "", strtar_mark="",tclass = "", tclass1 = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

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

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            HTProgCode = "Brt71";
            tblname = "dmt_temp_ap";
        } else if (qs_dept == "e") {
            HTProgCode = "Ext71";
            tblname = "caseext_apcust";
        }
         
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title+"-開立對象輸入";
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=\"Ext71_Query.aspx?prgid=" + prgid + "&gs_dept=" + qs_dept + "\" target=\"Eblank\">[客戶查詢]</a>\n";
        StrFormBtnTop += "<a href=\"Ext71_Query.aspx?prgid=" + prgid + "&gs_dept=" + qs_dept + "\" target=\"Eblank\">[申請人查詢]</a>\n";
        if ((HTProgRight & 2) > 0) {
            StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"下一步\" class=\"cbutton bsubmit\" />\n";
            StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }

        //抓取收據抬頭ID及名稱
        if (ReqVal.TryGet("apsqlno") != "") {
            SQL = "select apcust_no,ap_cname1,ap_cname2 from apcust where apsqlno=" + ReqVal.TryGet("apsqlno");
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.Read()) {
                    apcust_no = dr0.SafeRead("apcust_no", "");
                    ap_cname = dr0.SafeRead("ap_cname1", "") + dr0.SafeRead("ap_cname2", "");
                }
            }
        }
        //請款單種類
         if (ReqVal.TryGet("tar_mark") == "D") {
	        strtar_mark = "D";//請款註記，D扣收入
         }else{
	        strtar_mark = "A";//請款註記，其餘者
         }
            
        if (ReqVal.TryGet("case_date") != "") {
            tclass = "Lock";
            tclass1 = "Lock";
        }
    
        //營洽清單
        DataTable dt = new DataTable();
        if ((HTProgRight & 64) != 0) {
            SQL = "select scode,sc_name from sysctrl.dbo.vscode_type where branch='" + Session["seBranch"] + "' and grpid like '" + Session["Dept"] + "%' and work_type='sales' order by scode";
            conn.DataTable(SQL, dt);
            td_tscode = "<select id='Scode' name='Scode'>" + dt.Option("{scode}", "{scode}_{sc_name}", false, Sys.GetSession("scode")) + "</select>";
        } else {
            td_tscode = "<input type='text' id='Scode' name='Scode' readonly class='SEdit' value='" + Session["se_scode"] + "'>";
            td_tscode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
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

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="text" id="myobject" name="myobject">
    <input type="text" id="apsqlno" name="apsqlno">
    <input type="text" id="id_no" name="id_no">
    <input type="text" id="Type" name="Type" value=<%=Request["Type"]%>>
    <input type="text" id="qs_dept" name="qs_dept" value=<%=Request["qs_dept"]%>>
    <input type="text" id=cust_seq  name=cust_seq value=>
    <input type="text" id=rec_scode name=rec_scode value=>
    <input type="text" id=inscode1  name=inscode1 value=<%=Request["in_scode"]%>>
    <input type="text" id=inno1 name=inno1 value=<%=Request["in_no"]%>>
    <input type="text" id=T1 name=T1 value="Y">
    <input type="text" id=rec_chk1 name=rec_chk1 value="N"><!--檢附間接委辦單-->
    <input type="text" id=receipt name=receipt value=<%=Request["receipt"]%>>

    <div id="id-div-slide">
        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center">
	        <tr>
		        <td class=lightbluetable align=right >營洽人員：</td>
		        <TD class=whitetablebg align=left colspan=3 ><%#td_tscode%></TD>
	        </tr>
	        <TR id=showcust>
		        <TD class=lightbluetable align=right >案件所屬客戶：</TD>
		        <TD class=whitetablebg align=left ><INPUT type=text id="tfx_Cust_area" name="tfx_Cust_area" readonly value="<%=Session["seBranch"]%>" class="sedit" size="1">-<INPUT type="text" id="tfx_Cust_seq" name="tfx_Cust_seq" size="10%" value="<%=Request["cust_seq"]%>" <%=tclass1%> onblur="search(this.value,'C','C')"></td>
		        <td class=whitetablebg1 align=left ><INPUT type=text id="cust_cname" name="cust_cname" size=60 readonly class="sedit" ></TD>	
	        </TR>
	        <tr>
	            <td class=lightbluetable align=right>收據抬頭：</td>
	            <TD class=whitetablebg align=left >
	                <label><input type=radio name=tobject value="1" onclick="discase('C')">該客戶</label>
	                <label><input type=radio name=tobject value="2" onclick="discase('A')">案件申請人</label>
	            </TD>
	            <TD class=whitetablebg align=left >
	                <label><input type=checkbox id="tfx_rec_chk1" name="tfx_rec_chk1" disabled onclick="rec_chk71()">檢附間接委辦單</label>
	            </td>    
	        </tr>
	        <TR id=showap>
		        <TD class=lightbluetable align=right >ID：</TD>
		        <TD class=whitetablebg align=left ><INPUT type=text id="tfx_apcust_no" name="tfx_apcust_no" size="10" onblur="search(this.value,'A','A')" value=<%=apcust_no%>>(統編或身分證字號)</td>
		        <TD class=whitetablebg align=left><INPUT type=text id="ap_cname" name="ap_cname" size=60 readonly class="sedit" value=<%=ap_cname%>>
                     <input type="button" name="btngetap" id="btngetap" class="c1button" style="display:none" value="共同申請人">
                </TD>	
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">案件何時交辦：</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <input type="text" id="Sdate" name="Sdate" size="10" readonly class="dateField">～
		            <input type="text" id="Edate" name="Edate" size="10" readonly class="dateField">
		            <label><input type="checkbox" name="daterange" checked>不指定</label>
		        </td>
	        </tr>
	        <tr>
		        <td class="lightbluetable" align="right">請款單種類：</td>
		        <td class="whitetablebg" align="left" colspan=3>
		            <label><input type="radio" name="tfx_ar_mark" <%=tclass%> value="A" title="一般請款單" <%=(strtar_mark=="A"?"checked":"")%> onclick="armark_chk71(this.value)">一般+實報實銷案件</label>
		            <label><input type="radio" name="tfx_ar_mark" <%=tclass%> value="D" title="此請款單為扣收入，不寄給客戶" <%=(strtar_mark=="D"?"checked":"")%> onclick="armark_chk71(this.value)">扣收入案件(不開收據)</label>
		            <input type="text" id="tar_mark" name="tar_mark" value=<%=Request["tar_mark"]%>>
		        </td>	
	        </tr>
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
        }

        if("<%=ReqVal.TryGet("case_date")%>"!=""){
            $("#Sdate").val("<%=ReqVal.TryGet("case_date")%>");
            $("#Edate").val("<%#DateTime.Today.ToShortDateString()%>");
            $("input[name='daterange']").prop("checked",false);
        }
		
        if("<%=ReqVal.TryGet("cust_seq")%>"!=""){
            search("<%=ReqVal.TryGet("cust_seq")%>","C","C");
        }

        //預設案件申請人
        $("input[name='tobject'][value='2']").prop("checked",true).triggerHandler("click");

        if("<%=ReqVal.TryGet("apsqlno")%>"!=""){
            search("<%=ReqVal.TryGet("cust_seq")%>","A","A");
        }

        if($("#inno1").val()!=""&&$("#inscode1").val()!=""){
            getapnum();
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    $(".dateField").blur(function (e) {
        ChkDate(this);
    });
    //////////////////////////////////////////////////////

    //[重填]
    $("#btnRest").click(function (e) {
        reg.reset();
        this_init();
    });

    //檢查客戶/申請人
    //tobject:A=查apcust_no,C/S=查cust_seq
    //tca:C=客戶,其他=申請人
    function search(tno, tobject, tca) {
        if (tno == ""){
            if (tca == "C"){
                alert("輸入請款客戶錯誤，請重新輸入");
            }else{
                alert("輸入開立對象錯誤，請重新輸入");
            }
           return false;
        }
		
        //*******抓取開立對象名稱，證照號碼
        var url="";
        if (tobject=="C"||tobject=="S"){
            url=getRootPath() + "/ajax/_apcust.aspx?cust_seq=" + tno ;
        }else{
            url=getRootPath() + "/ajax/_apcust.aspx?apcust_no=" + tno;
        }

        $.ajax({
            type: "get",
            url: url,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").length > 0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(search)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert("無該客戶/申請人資料");
                    return false;
                } else {
                    $("#apsqlno").val(JSONdata[0].apsqlno);
                    $("#tfx_apcust_no").val(JSONdata[0].apcust_no);
                    $("#ap_cname").val(JSONdata[0].ap_name);
                    if (tca == "C"){
                        $("#cust_cname").val($("#ap_cname").val());//申請人名稱
                        $("#id_no").val($("#tfx_apcust_no").val());//申請人統編或身分證字號
                    }
                }
            },
            error: function (xhr) { 
                $("#dialog").html("<a href='" + this.url + "' target='_new'>客戶/申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                $("#dialog").dialog({ title: '客戶/申請人資料載入失敗！', modal: true, maxHeight: 500,width: "90%" });
            }
        });
    }

    //依接洽資料抓取交辦申請人數
    function getapnum() {
        var searchSql = "select count(*) as apnum from <%=tblname%> where in_no='" + $("#inno1").val() + "'";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert("無該交辦案件申請人資料!!");
                    return false;
                } else {
                    if (CInt(JSONdata[0].apnum) > 1) {
                        $("#btngetap").val("共同申請人(" + JSONdata[0].apnum + ")");
                        $("#btngetap").show();
                    }
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取交辦申請人數失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取交辦申請人數失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //收據抬頭
    function discase(x) {
        $("#myobject").val(x);

        if (x == "C") {//該客戶
            $("#tfx_apcust_no").val($("#id_no").val());
            $("#tfx_apcust_no").lock();
            $("#tfx_rec_chk1").prop("checked", true);
            $("#rec_chk1").val("Y");
            search($("#tfx_Cust_seq").val(), 'C', 'C');
        }

        if (x == "A" || x == "S") {//案件申請人
            $("#tfx_apcust_no").unlock();
            $("#tfx_rec_chk1").prop("checked", false);
            $("#rec_chk1").val("N");
            if ("<%=ReqVal.TryGet("case_date")%>" != "") {
                $("#tfx_apcust_no").val("<%=apcust_no%>");
                search($("#tfx_apcust_no").val(), "A", "A");
            }
        }
    }

    //檢附間接委辦單
    function rec_chk71() {
        if ($("#tfx_rec_chk1").prop("checked") == true) {
            $("#rec_chk1").val("Y");
        } else {
            $("#rec_chk1").val("N");
        }
    }
	
    //請款單種類
    function armark_chk71(v){
        $("#tar_mark").val(v);
    }
    
    //當從請款查詢進入時，檢查輸入證照號碼是否為該案件申請人
    function apcust_chk71(){
        var searchSql = "select count(*) as apnum from <%=tblname%> where in_no='" + $("#inno1").val() + "'";
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: searchSql },
            async: false,
            cache: false,
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length == 0) {
                    alert("無該交辦案件申請人資料!!");
                    return false;
                } else {
                    if (CInt(JSONdata[0].apnum) > 1) {
                        $("#btngetap").val("共同申請人(" + JSONdata[0].apnum + ")");
                        $("#btngetap").show();
                    }
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取交辦申請人數失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取交辦申請人數失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });

        var searchSql = "select b.apcust_no,a.apsqlno from <%=tblname%> a inner join apcust b on a.apsqlno=b.apsqlno where a.in_no='<%=Request["in_no"]%>'";

        <%	sqlfind = "select b.apcust_no,a.apsqlno from <%=tblname%> a inner join apcust b on a.apsqlno=b.apsqlno where a.in_no='" & request("in_no") & "'"
		RTreg.open sqlfind,conn,1,1
		int_flag=false
		while not RTreg.eof			
			tapcust_no=trim(RTreg("apcust_no"))
	        %>			
            if trim(reg.tfx_apcust_no.value) = "<%=tapcust_no%>" then
                apcust_chk71=true
                exit function
            end if
	<%      RTreg.movenext
		wend
		if int_flag=false then 
	%>	
			apcust_chk71=false
	<%	end if%>
    }


        //[下一步]
        $("#btnSrch").click(function (e) {
            if ($("input[name=todo][value='X']").prop("checked") == true) {//交辦尚未請款完畢
                if ($("#Scode").val() == "") {
                    alert("請選擇營洽人員！");
                    return false;
                }
            }

            if ($("#eseq").val() == "" && $("#bseq").val() != "") {
                $("#eseq").val($("#bseq").val());
            }

            reg.action = "<%=HTProgPrefix%>_List.aspx";//未開立請款單案件查詢
            reg.submit();
        });
</script>
