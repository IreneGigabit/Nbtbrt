<%@ Control Language="C#" ClassName="opt_bc1_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";

    protected string html_Pagt_no = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";

        html_Pagt_no = Sys.getAgent().Option("{agt_no}", "{strcomp_name}{agt_name}");
      
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" valign="top"><strong>※、代理人</strong></td>
		<td class="whitetablebg" colspan="3" valign="top">
		    <select id=Pagt_no NAME=Pagt_no class="QLock"><%#html_Pagt_no%></select>
		</td>
	</tr>	
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%">
            <strong>壹、申請<span id="span_case">舉行</span>聽證的案件</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>商標種類：</td>
		<td class=whitetablebg colspan="3" >
			<input type=radio name=PS_Mark value="" class="QLock">商標
			<input type=radio name=PS_Mark value="S" class="QLock">92年修正前服務標章
			<input type=radio name=PS_Mark value="N" class="QLock">團體商標
			<input type=radio name=PS_Mark value="M" class="QLock">團體標章
			<input type=radio name=PS_Mark value="L" class="QLock">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="20%">註冊號數：</td>
		<td class=whitetablebg width="30%">
			<input type="text" id="Pissue_no" name="Pissue_no" size="20" maxlength="20" class="QLock">
		</TD>
		<td class=lightbluetable align=right width="20%">商標/標章名稱：</td>
		<td class=whitetablebg width="30%">
			<input type="text" id="PAppl_name" name="PAppl_name" size="40" maxlength="100" class="QLock">
		</TD>
	</tr>
	<tr id="tr_remark3">
		<td class=lightbluetable align=right >案件種類：</td>
		<td class=whitetablebg colspan="3">
			<input type=radio name=Premark3 value="DI1" class="PLock">評定案件
			<input type=radio name=Premark3 value="DO1" class="PLock">異議案件
			<input type=radio name=Premark3 value="DR1" class="PLock">廢止案件
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>貳、申請人</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >種　　類：</td>
		<td class=whitetablebg colspan="3">
			評定案件或異議案件或廢止案件之<input type=radio name=PMark value='A' class="PLock">申請人<input type=radio name=PMark value='I' class="PLock">註冊人
		</TD>
	</tr>
		
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%"><strong>肆、對造當事人</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >種　　類：</td>
		<td class=whitetablebg colspan="3">評定案件或異議案件或廢止案件之
			<input type=radio name=Ptran_mark value="I" class="PLock">註冊人
			<input type=radio name=Ptran_mark value="A" class="PLock">申請人
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>代 理 人 ：</td>
		<td class=whitetablebg colspan="3">
			<input type=text id=Pother_item2 name=Pother_item2 size="33" maxlength="30" class="PLock">
		</TD>
	</tr>
	<!--DE1 or AD7申請聽證之對造當事人 start-->
	<tr class='sfont9'>
		<td colspan="4">
            <table border="0" id=DE1_tabap class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	            <THEAD>
		            <TR>
			            <TD class=whitetablebg colspan=2 align=right>
                            <input type=hidden id=DE1_apnum name=DE1_apnum value=0><!--進度筆數-->
				            <input type=button value ="增加一筆對造當事人" class="cbutton PLock" id=DE1_AP_Add_button name="DE1_AP_Add_button">
				            <input type=button value ="減少一筆對造當事人" class="cbutton PLock" id=DE1_AP_Del_button name="DE1_AP_Del_button">
			            </TD>
		            </TR>
	            </THEAD>
	            <TFOOT style="display:none">
		            <TR>
			            <TD class=lightbluetable align=right>
		                    <input type=text name='DE1_apnum_##' class="Lock" style='color:black;' size=2 value='##.'>名稱：
			            </TD>
			            <TD class=sfont9>
		                    <input TYPE=text ID="tfr4_ncname1_##" NAME="tfr4_ncname1_##" SIZE=60 MAXLENGTH=60 alt='『名稱』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
			            </TD>
		            </TR>
		            <TR>
			            <TD class=lightbluetable align=right>地址：</TD>
			            <TD class=sfont9>
		                    <INPUT TYPE=text id="tfr4_naddr1_##" name="tfr4_naddr1_##" SIZE=60 MAXLENGTH=60 alt='『地址』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
			            </TD>
		            </TR>
	            </TFOOT>
	            <TBODY>
	            </TBODY>
            </table>
		</td>
	</tr>
	<!--DE1申請聽證之對造當事人 end-->
	<tr>
		<td class="lightbluetable" colspan="4" valign="top" width="20%">
            <strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font></td>
	</tr>
	<TR>
		<TD class=whitetablebg colspan="4">
		<TEXTAREA id=Ptran_remark1 name=Ptran_remark1 ROWS=6 COLS=100 class="PLock"></TEXTAREA>
		</TD>
	</TR>	
</table>	


<script language="javascript" type="text/javascript">
    var tran_form = {};
    tran_form.init = function () {
        //$("#Pagt_no").getOption({//代理人
        //    url: getRootPath() + "/ajax/LookupDataBranch.aspx",
        //    data: { type: "getagtdata", branch: "<%#branch%>" },
        //    valueFormat: "{agt_no}",
        //    textFormat: "{strcomp_name}{agt_name}"
        //});

        var jOpt = br_opt.opt[0];
        $("#Pagt_no").val(jOpt.agt_no);
        $("#Pissue_no").val(jOpt.issue_no);
        $("#PAppl_name").val(jOpt.appl_name);
        $("#Pother_item2").val(jOpt.other_item2);
        $("#Ptran_remark1").val(jOpt.tran_remark1);
        $("input[name='PS_Mark'][value='" + jOpt.s_mark + "']").prop("checked", true);
        $("input[name='Premark3'][value='" + jOpt.remark3 + "']").prop("checked", true);
        $("input[name='PMark'][value='" + jOpt.detail_mark + "']").prop("checked", true);
        $("input[name='Ptran_mark'][value='" + jOpt.tran_mark + "']").prop("checked", true);

        //對造人
        var jMod = br_opt.tran_mod_client;
        $("#DE1_tabap>tbody").empty();
        if (jMod.length > 0) {
            $.each(jMod, function (i, item) {
                //增加一筆
                tran_form.appendTran()
                //填資料
                var nRow = $("#apnum").val();
                $("#tfr4_ncname1_" + nRow).val(item.ncname1);
                $("#tfr4_naddr1_" + nRow).val(item.naddr1);
            });
        } else {
            alert("查無此交辦案件之對造當事人資料!!");
        }
    }

    //增加一筆對造人資料
    $("#DE1_AP_Add_button").click(function () { tran_form.appendTran(); });
    tran_form.appendTran = function () {
        var nRow = parseInt($("#DE1_apnum").val(), 10) + 1;
        //複製樣板
        var copyStr = "";
        $("#DE1_tabap>tfoot tr").each(function (i) {
            copyStr += "<tr name='tr_tran_"+nRow+"'>" + $(this).html().replace(/##/g, nRow) + "</tr>"
        });
        //$("#DE1_tabap>tbody").append("<tr id='tr_ap_" + nRow + "' class='sfont9'><td><table border='0' class='bluetable' cellspacing='1' cellpadding='2' width='100%'>" + copyStr + "</table></tr></td>");
        $("#DE1_tabap>tbody").append(copyStr);
        $("#DE1_apnum").val(nRow)
    }

    //減少一筆申請人
    $("#DE1_AP_Del_button").click(function () { tran_form.deleteTran(); });
    tran_form.deleteTran = function () {
        var nRow = parseInt($("#DE1_apnum").val(), 10);
        $("tr[name='tr_tran_" + nRow+"']").remove();
        $("#DE1_apnum").val(Math.max(0, nRow - 1));
    }
</script>
