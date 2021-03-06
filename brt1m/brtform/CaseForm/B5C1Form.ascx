﻿<%@ Control Language="C#" ClassName="B5C1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //BZZ交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string tfp4_agt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfp4_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_B5C1">
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfp4_agt_no" NAME="tfp4_agt_no" onchange="br_form.copycaseZZ('tfp4_agt_no')"><%#tfp4_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>壹、申請<span id="span_case">舉行</span>聽證的案件</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>商標種類：</td>
		<td class=whitetablebg colspan="3" >
			<input type=radio name=fr4_S_Mark class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=fr4_S_Mark class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=fr4_S_Mark class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=fr4_S_Mark class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=fr4_S_Mark class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="20%">註冊號數：</td>
		<td class=whitetablebg width="30%">
			<input type="text" id="fr4_issue_no" name="fr4_issue_no" value="" size="20" maxlength="20" onchange="reg.tfzd_issue_no.value=this.value">
		</TD>
		<td class=lightbluetable align=right width="20%">商標/標章名稱：</td>
		<td class=whitetablebg width="30%">
			<input type="text" id="fr4_appl_name" name="fr4_appl_name" value="" size="40" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
	<tr id="tr_remark3" style="display:none">
		<td class=lightbluetable align=right >案件種類：</td>
		<td class=whitetablebg colspan="3">
			<input type=radio name=fr4_remark3 value="DI1">評定案件
			<input type=radio name=fr4_remark3 value="DO1">異議案件
			<input type=radio name=fr4_remark3 value="DR1">廢止案件
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>貳、申請人</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >種　　類：</td>
		<td class=whitetablebg colspan="3">
			<span id="span_dmttemp_mark">
			    <input type=radio name=fr4_Mark value="B">爭議案申請人或異議人
			    <input type=radio name=fr4_Mark value="I">系爭商標商標權人
			    <input type=radio name=fr4_Mark value="R">利害關係人
			</span>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong><span id="span_case1">參、出席代表姓名或代理姓名</span></strong></td>
	</tr>
	<tr id="tr_tran_mark" style="display:none">
		<td class=lightbluetable align=right >種　　類：</td>
		<td class=whitetablebg colspan="3">評定案件或異議案件或廢止案件之
			<input type=radio name=fr4_tran_mark value="I" class="<%#Lock.TryGet("Qdisabled")%>">註冊人
			<input type=radio name=fr4_tran_mark value="A" class="<%#Lock.TryGet("Qdisabled")%>">申請人
		</TD>
	</tr>
	<tr id="tr_de2_item">
		<td class=lightbluetable align=right><span id="span_other_item">指定發言姓名</span>：</td>
		<td class=whitetablebg colspan="3">
			<input type=text id=fr4_other_item name=fr4_other_item value="" size="55" maxlength="50">
		</TD>
	</tr>
	<tr id="tr_de2_item1">
		<td class=lightbluetable align=right><span id="span_other_item1">職　　稱</span>：</td>
		<td class=whitetablebg colspan="3">
			<input type=text id=fr4_other_item1 name=fr4_other_item1 value="" size="55" maxlength="50">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right><span id="span_other_item2">聯絡電話</span>：</td>
		<td class=whitetablebg colspan="3">
			<input type=text id=fr4_other_item2 name=fr4_other_item2 value="" size="33" maxlength="30" >
		</TD>
	</tr>
	<!--DE1 or AD7申請聽證之對造當事人 start-->
	<tr id="tr_de1_ap" style="display:none">
		<td colspan="4" class='sfont9'>
		    <input type=hidden id=DE1_apnum name=DE1_apnum value=0><!--進度筆數-->
		    <table border="0" id=DE1_tabap class="bluetable" cellspacing="1" cellpadding="1" width="100%">
            <thead>
		        <TR>
			        <TD  class=whitetablebg colspan=2 align=right>
				        <input type=button value ="增加一筆對造當事人" class="cbutton" id=DE1_AP_Add_button name=DE1_AP_Add_button>
				        <input type=button value ="減少一筆對造當事人" class="cbutton" id=DE1_AP_Del_button name=DE1_AP_Del_button>
			        </TD>
		        </TR>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="de1_ap_template">
	            <TR>
		            <TD class=lightbluetable align=right>
			            <input type=text id='DE1_apnum_##' name='DE1_apnum_##' class=SEdit readonly style='color:black;' size=2 value='##.'>名稱：
		            </TD>
		            <TD class=whitetablebg>
		                <input TYPE=text id=tfr4_ncname1_## NAME=tfr4_ncname1_## SIZE=60 MAXLENGTH=60 alt='『名稱』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
	            <TR>
		            <TD class=lightbluetable align=right>
			            地址：
		            </TD>
		            <TD class=whitetablebg>
		                <INPUT TYPE=text id=tfr4_naddr1_## name=tfr4_naddr1_## SIZE=60 MAXLENGTH=60 alt='『地址』' onblur='fDataLen(this)'>
		            </TD>
	            </TR>
            </script>
		    </table>
		</td>
	</tr>
	<!--DE1申請聽證之對造當事人 end-->
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><span id="span_tran_remark1">附註：新事證及陳述意見書</span></td>
	</tr>
	<TR>
		<TD class=whitetablebg colspan="4">
		    <TEXTAREA id=fr4_tran_remark1 NAME=fr4_tran_remark1 ROWS=6 COLS=100></TEXTAREA>
		</TD>
	</TR>
</table>
</div>

<script language="javascript" type="text/javascript">
    //增加一筆對造當事人
    $("#DE1_AP_Add_button").click(function () {
        var nRow = CInt($("#DE1_apnum").val()) + 1;
        //複製樣板
        var copyStr = $("#de1_ap_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);

        $("#DE1_tabap>tbody").append("<tr id='tr_de1_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></td></tr>");
        $("#tr_de1_" + nRow + " .Lock").lock();
        $("#DE1_apnum").val(nRow);
    });

    //減少一筆對造當事人
    $("#DE1_AP_Del_button").click(function () {
        var nRow = CInt($("#DE1_apnum").val());
        $('#tr_de1_' + nRow).remove();
        $("#DE1_apnum").val(Math.max(0, nRow - 1));
    });

    //交辦內容綁定
    br_form.bindB5C1 = function () {
        console.log("b5c1.br_form.bind");
        if (jMain.case_main.length == 0) {
            $("#DE1_AP_Add_button").click();//對造當事人預設顯示第1筆
        } else {
            $("#tfp4_agt_no").val(jMain.case_main[0].agt_no);
            //商標種類
            $("input[name=fr4_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            $("#fr4_issue_no").val(jMain.case_main[0].issue_no);//註冊號數
            $("#fr4_appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            //案件種類
            $("input[name=fr4_remark3][value='" + jMain.case_main[0].remark3 + "']").prop("checked", true);
            //申請人種類
            $("input[name=fr4_Mark][value='" + jMain.case_main[0].temp_mark + "']").prop("checked", true);
            //出席代表種類
            $("input[name=fr4_tran_mark][value='" + jMain.case_main[0].tran_mark + "']").prop("checked", true);
            $("#fr4_other_item").val(jMain.case_main[0].other_item);//指定發言姓名
            $("#fr4_other_item1").val(jMain.case_main[0].other_item1);//職稱
            $("#fr4_other_item2").val(jMain.case_main[0].other_item2);//聯絡電話

            if ($("#tfy_Arcase").val().Left(3) == "DE1"||$("#tfy_Arcase").val().Left(3) == "AD7") {
                //對造當事人
                $.each(jMain.case_tranlist, function (i, item) {
                    if (item.mod_field == "mod_client") {
                        //增加一筆
                        $("#DE1_AP_Add_button").click();
                        //填資料
                        var nRow = $("#DE1_apnum").val();
                        $("#tfr4_ncname1_" + nRow).val(item.ncname1);
                        $("#tfr4_naddr1_" + nRow).val(item.naddr1);
                    }
                });
                if (CInt($("#DE1_apnum").val()) == 0) {
                    alert("查無此交辦案件之對造當事人資料!!");
                }
            }
            $("#fr4_tran_remark1").val(jMain.case_main[0].tran_remark1);
        }
    }
</script>
