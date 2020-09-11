<%@ Control Language="C#" ClassName="show_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
    }
</script>

<tr>
	<td colspan=8 class="whitetablebg">
		<input type=hidden id=shownum name=shownum value="0">
		<TABLE id=tabshow border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
            <thead>
		    <tr>
			    <td class="lightbluetable" colspan="3" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ><strong>參、<u>展覽會優先權聲明</u></strong></td>
		    </tr>
		    <TR class=whitetablebg align=center>
			    <TD colspan=3 >
				    <input type=button value ="增加一筆展覽會優先權" class="cbutton" id=show_Add_button name=show_Add_button_FA1 onclick="show_form.add_show()">			
				    <input type=button value ="減少一筆展覽會優先權" class="cbutton" id=show_Del_button name=show_Del_button_FA1 onclick="show_form.del_show()">
			    </TD>
		    </TR>
		    <tr>
			    <td class="lightbluetable" align="center" ></td>	
			    <td class="lightbluetable" align="center" >展覽會優先權日</td>
			    <td class="lightbluetable" align="center" >展覽會名稱</td>	
		    </tr>
            </thead>
            <tbody>
            </tbody>
            <script type="text/html" id="show_template"><!--展覽會優先權樣板-->
	            <tr id=tr_show_##>
		            <td class=whitetablebg align=center>
                        <input type=text id='shownum_##' name='shownum_##' class=SEdit readonly size=2 value='##.'>
                        <input type=hidden id='show_sqlno_##' name='show_sqlno_##'>
		            </td>
		            <td class=whitetablebg align=center>
		                <input type=text size=10 maxlength=10 id='show_date_##' name='show_date_##' onblur="show_form.chk_showdate('##')" class="dateField">
		            </td>
		            <td class=whitetablebg align=center>
		                <input type=text id='show_name_##' name='show_name_##' size=50 maxlength=100>
		            </td>
	            </tr>
            </script>
		</table>
	</td>	
</tr>

<script language="javascript" type="text/javascript">
var show_form={};
//展覽優先權增加一筆
show_form.add_show = function () {
    var nRow = parseInt($("#shownum").val(), 10) + 1;
    //複製樣板
    var copyStr = $("#show_template").text() || "";
    copyStr = copyStr.replace(/##/g, nRow);
    $("#tabshow tbody").append(copyStr);
    $("#shownum").val(nRow);
    $(".dateField", $('#tr_show_' + nRow)).datepick();
}

//展覽優先權減少一筆
show_form.del_show = function () {
    var nRow = CInt($("#shownum").val());
    $('#tr_show_' + nRow).remove();
    $("#shownum").val(Math.max(0, nRow - 1));
}

//檢查展覽優先權日期
show_form.chk_showdate = function (pno) {
    ChkDate($("#show_date_" + pno)[0]);

    if ($("#show_date_" + pno).val() != "") {
        var sdate = new Date($("#show_date_" + pno).val()).setHours(0, 0, 0, 0);
        var today = new Date().setHours(0, 0, 0, 0);
        if (sdate > today) {
            alert("展覽優先權日期不可大於系統日期!!");
            $("#show_date_" + pno).focus();
        }
    }
}
</script>
