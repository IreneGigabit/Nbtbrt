<%@ Control Language="C#" ClassName="custForm" %>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string branch = "";
    protected string dept = "";
    //營洽選單
    protected string html_scode = "";

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        branch = Sys.GetSession("seBranch");
        dept = Sys.GetSession("dept");
        if (Sys.GetSession("dept") == "P")
        {
            html_scode = Sys.getCustScode("Q", "P", 64, "").Option("{pscode}", "{pscode}_{sc_name}");
            html_scode += "<option value='np'>np_部門(開放客戶)</option>";
        }
        else
        {
            html_scode = Sys.getCustScode("Q", "T", 64, "").Option("{tscode}", "{tscode}_{sc_name}");
            html_scode += "<option value='nt'>nt_部門(開放客戶)</option>";
        }
    
    }

</script>

<center>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="60%">
<TR>
    <TD class=lightbluetable align=right style="width:30%"><%=(prgid == "cust21") ? "客戶編號" : "申請人編號"%>：</TD>
	<TD class=whitetablebg align=left style="width:50%">
        <span id="s_custz">
            <INPUT type=text name="qrycust_area" id="qrycust_area" readonly class="SEdit" size="1" value="<%=branch%>">-
	        <INPUT type="text" name="qrycust_seq" id="qrycust_seq" maxlength="5" size="6">
        </span>
        <INPUT type="text" name="qryapcust_no" id="qryapcust_no" maxlength="10" size="11">
	    <INPUT type="hidden" name="qrycust_name" readonly class="sedit" size="30" >
    </TD>
</TR>
<tr><TD class=lightbluetable align=right>部門別：</TD>
	<TD class=whitetablebg align=left>
		<INPUT type="radio" name="qrydept" id="deptdmp" value="P"><span id="deptdmpName">國內專利</span>
		<INPUT type="radio" name="qrydept" id="deptexp" value="PE"><span id="deptexpName">出口專利</span>
		<INPUT type="radio" name="qrydept" id="deptdmt" value="T"><span id="deptdmtName">國內商標</span>
		<INPUT type="radio" name="qrydept" id="deptext" value="TE"><span id="deptextName">出口商標</span>
	</TD>
</tr>
<tr><TD class=lightbluetable align=right>接洽人員：</TD>
	<TD class=whitetablebg align=left>
		<input type="hidden" name="pwhescode">
		<Select NAME="qryscode" id="qryscode" size=1>
		<%--<%if (HTProgRight AND 128) <> 0 or (HTProgRight AND 64) <> 0 then%>--%>
			<%--<option value="<%=ucase(session("se_Branch"))%><%=ucase(session("Dept"))%>">部門(開放客戶)</option>--%>
		<%=html_scode%>
            <option value="all">全部</option>
		</SELECT>
	</TD>
</tr>
<tr><TD class=lightbluetable align=right><%=(prgid == "cust21")?"契約書號碼":"委任書號碼"%>：</TD>
	<TD class=whitetablebg align=left>
		<INPUT type="text" name="qrycontract_nos" id="qrycontract_nos" size="11" maxlength=10>
		～<INPUT type="text" name="qrycontract_noe" id="qrycontract_noe" size="11" maxlength=10>
	</TD>
</tr>
<tr><TD class=lightbluetable align=right>簽約期間：</TD>
	<TD class=whitetablebg align=left>
        <input type="text" name="qrycontract_sdate" id="qrycontract_sdate" size="10" readonly="readonly" class="dateField">～
		<input type="text" name="qrycontract_edate" id="qrycontract_edate" size="10" readonly="readonly" class="dateField">
	</TD>
</tr>
<tr><TD class=lightbluetable align=right>到期日期：</TD>
	<TD class=whitetablebg align=left>
		～<input type="text" name="qryuse_date" id="qryuse_date" size="10" readonly="readonly" class="dateField">
	</TD>
</tr>
<tr>
    <TD class=lightbluetable align=right>狀態：</TD>
	<TD class=whitetablebg align=left>
		<INPUT type="radio" name="qryattach_flag" onclick="custForm.skind_onclick('U')" value="U" checked>使用中
		<INPUT type="radio" name="qryattach_flag" onclick="custForm.skind_onclick('E')"  value="E">已停用
		<INPUT type="radio" name="qryattach_flag" onclick="custForm.skind_onclick('')" value="">不指定<br />
        <span id="showinclude">
            <input type="checkbox" name="includeexpired" id="includeexpired" value="Y" />含逾期
        </span>
	</TD>
</tr>
<tr id="tr_qryid_no">
    <TD class=lightbluetable align=right>証照號碼：</TD>
	<TD class=whitetablebg align=left><INPUT type="text" name="qryid_no" id="qryid_no" size="11" maxlength=10></TD>
</tr>
<TR>
	<TD class=lightbluetable align=right><%=(prgid == "cust21")?"客戶":"申請人"%>名稱(中)：</TD>
	<TD class=whitetablebg align=left><INPUT type=text name="qryap_cname" id="qryap_cname" size="22" maxlength="30" value=""></TD>
</tr>
<TR>
	<TD class=lightbluetable align=right><%=(prgid == "cust21")?"客戶":"申請人"%>名稱(英)：</TD>
	<TD class=whitetablebg align=left><INPUT type=text name="qryap_ename" id="qryap_ename" size="22" maxlength=40></TD>
</TR>
</TABLE>
</center>

<script language="javascript" type="text/javascript">

    var custForm = {};
    custForm.init = function () {
        if ('<%=dept%>' == 'P') {
            $("#deptdmt, #deptext").hide();
            $("#deptdmtName, #deptextName").hide();
            $("#deptdmp").prop("checked", true);
        }
        else {
            $("#deptdmp, #deptexp").hide();
            $("#deptdmpName, #deptexpName").hide();
            $("#deptdmt").prop("checked", true);
        }

        if ('<%=prgid%>' == "cust21") {
            $("#qryapcust_no").hide();
        }
        else {
            //$("#qrycust_area, #qrycust_seq, #tr_qryid_no").hide();
            $("#s_custz, #tr_qryid_no").hide();
            $("#showinclude").hide();
            $("input[name=qryattach_flag]").each(function () {
                $(this).prop("onclick", null);
            })
        }


        $("input.dateField").datepick();
    }

    custForm.skind_onclick = function (pi) {
        if (pi == "") {
            document.all.showinclude.style.display = "none";
            $("#includeexpired").prop("checked", false);
        }
        else {
            document.all.showinclude.style.display = "";
            $("#includeexpired").show();
            if (pi == "U") {
                $("#includeexpired").prop("checked", false);
            }
            else {
                $("#includeexpired").prop("checked", true);
            }
        }
    }




</script>