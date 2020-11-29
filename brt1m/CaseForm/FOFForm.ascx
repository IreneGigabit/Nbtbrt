<%@ Control Language="C#" ClassName="FOFForm" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //ZZ交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfzf_agt_no1 = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();   
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfzf_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
    }
</script>

<div id="div_Form_FOF">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>參、代理人</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="tfzf_agt_no1" NAME="tfzf_agt_no1"><%#tfzf_agt_no1%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(FOFappl_name)">
            <strong>壹、<u>商標號數、商標/標章名稱、商標種類</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=frf_S_Mark value="" onclick="dmt_form.change_mark(1, this)">商標
			<input type=radio name=frf_S_Mark value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
			<input type=radio name=frf_S_Mark value="N" onclick="dmt_form.change_mark(1, this)">團體商標
			<input type=radio name=frf_S_Mark value="M" onclick="dmt_form.change_mark(1, this)">團體標章
			<input type=radio name=frf_S_Mark value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >申請/註冊號數：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=frf_mark value="A" onclick="br_form.change_no1('A')">申請
			<input type=radio name=frf_mark value="I" onclick="br_form.change_no1('I')">註冊
			&nbsp;&nbsp;號數：
			<input type="text" id="frf_no" name="frf_no" value="" size="20" maxlength="20" >
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標名稱：</td>
		<td class=whitetablebg colspan="7">
            <input type="text" id="frf_Appl_name" name="frf_Appl_name" value="" size="50" maxlength="100" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(FOFmark)"><strong>肆、<u>備註</u></strong></td>
	</tr>		
	<tr>
		<td class="lightbluetable" align="right"></td>
		<td class="whitetablebg" colspan="7">1.國庫支票抬頭名稱：<input type="text" id="tfzf_other_item" name="tfzf_other_item" size=20 maxlength=20></td>			
	</tr>
	<tr>
		<td class="lightbluetable" align="right"></td>
		<td class="whitetablebg" colspan="7">2.退費金額：新台幣<input type="text" id="tfzf_debit_money" name="tfzf_debit_money" size="10" maxlength="10">元整(規費收據號碼：<input type="text" id="tfzf_other_item1" name="tfzf_other_item1" size="20" maxlength="30">)</td>			
	</tr>
	<tr>
		<td class="lightbluetable" align="right" rowspan=2></td>
		<td class="whitetablebg" width="16%">3.本局通知退費函字號：</td>
		<td class="whitetablebg" colspan=6>
			<input type="radio" name="ttzf_F1" value="F1" onclick="br_form.CopyStr1(reg.tfzf_other_item2,'F1')">
			(<input type="text" id="F1_yy" name="F1_yy" size="3" maxlength="5" onblur="br_form.CopyStr1(reg.tfzf_other_item2,'F1')">)智商<input type="text" id="F1_word" name="F1_word" size="10" maxlength="20" onblur="br_form.CopyStr1(reg.tfzf_other_item2,'F1')">字第<input type="text" id="F1_no" name="F1_no" size=20 maxlength="30" onblur="br_form.CopyStr1(reg.tfzf_other_item2,'F1')">號函
		</td>
	</tr>
	<tr>
		<td class="whitetablebg" ></td>
		<td class="whitetablebg" colspan=6><input TYPE=hidden id="tfzf_other_item2" NAME="tfzf_other_item2" >
			<input type="radio" name="ttzf_F1" value="F2" onclick="br_form.CopyStr1(reg.tfzf_other_item2,'F2')">
			(<input type="text" id="F2_yy" name="F2_yy" size="3" maxlength="5" onblur="br_form.CopyStr1(reg.tfzf_other_item2,'F2')">)慧商<input type="text" id="F2_word" name="F2_word" size="10" maxlength="20" onblur="br_form.CopyStr1(reg.tfzf_other_item2,'F2')">字第<input type="text" id="F2_no" name="F2_no" size=20 maxlength="30" onblur="br_form.CopyStr1(reg.tfzf_other_item2,'F2')">號書函
		</td>
	</tr>
</table>
</div>

<script language="javascript" type="text/javascript">
    //代理人
    $("#tfzf_agt_no1").change(function (e) {
        var tagt_name="";
        var tselectedindex=$(this)[0].selectedIndex;
        if(tselectedindex>0){
            //2016/3/17修改，因出名代理人增加顯示代碼，所以抓取A19_後名稱
            //2020/6/19修改，改抓agt.agt_name1,不用文字切割
            tagt_name=$("#tfzf_agt_no1 option:selected").attr("v1");
        }
        $("#tfzf_other_item").val(tagt_name);
    });

    //申請/註冊號數
    br_form.change_no1 = function (x) {
        if(x=="A"){
            $("#frf_no").val($("#O_apply_no").val());
        }else if(x=="I"){
            $("#frf_no").val($("#O_issue_no").val());
        }
    }

    //號數
    $("#frf_no").blur(function (e) {
        $("#tfzd_apply_no").val($("#O_apply_no").val());
        $("#tfzd_issue_no").val($("#O_issue_no").val());
        
        if($("input[name='frf_mark']:checked").val() == "A"){
            $("#tfzd_apply_no").val($(this).val());
        }else if($("input[name='frf_mark']:checked").val() == "I"){
            $("#tfzd_issue_no").val($(this).val());
        }
    })
    
    //申請退費備註之通知退費函內容控制
    br_form.CopyStr1 = function (x, y) {
        //x=丟值reg.tfzf_oter_item2,y=勾選欄位名
        if (y == "F1") {
            $("input[name=ttzf_F1][value='F1']").prop("checked", true);
            $("#F2_yy,#F2_word,#F2_no").val("");
        } else if (y == "F2") {
            $("input[name=ttzf_F1][value='F2']").prop("checked", true);
            $("#F1_yy,#F1_word,#F1_no").val("");
        }
        x.value = y + "|" + $("#" + y + "_yy").val() + "|" + $("#" + y + "_word").val() + "|" + $("#" + y + "_no").val();
    }

    //交辦內容綁定
    br_form.bindFOF = function () {
        console.log("fof.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            $("#tfzf_agt_no1").val(jMain.case_main[0].agt_no);
            //商標種類
            $("input[name=frf_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            //申請/註冊號數
            $("input[name=frf_mark][value='" + jMain.case_main[0].mark + "']").prop("checked", true).triggerHandler("click");
            //號數
            if (jMain.case_main[0].mark == "A") {
                $("#no").val(jMain.case_main[0].apply_no);
            } else if (jMain.case_main[0].mark == "I") {
                $("#no").val(jMain.case_main[0].issue_no);
            }
            $("#frf_Appl_name").val(jMain.case_main[0].appl_name);//商標名稱
            $("#tfzf_other_item").val(jMain.case_main[0].other_item);//國庫支票抬頭名稱
            $("#tfzf_debit_money").val(jMain.case_main[0].debit_money);//退費金額
            $("#tfzf_other_item1").val(jMain.case_main[0].other_item1);//規費收據號碼
            $("#tfzf_other_item2").val(jMain.case_main[0].other_item2);//本局通知退費函字號
            if ($("#tfzf_other_item2").val() != "") {
                var strmark = $("#tfzf_other_item2").val().split("|");
                $("input[name=ttzf_F1][value='" + strmark[0] + "']").prop("checked", true);
                $("#" + strmark[0] + "_yy").val(strmark[1]);
                $("#" + strmark[0] + "_word").val(strmark[2]);
                $("#" + strmark[0] + "_no").val(strmark[3]);
            }
        }
        $("#tfzf_agt_no1").triggerHandler("change");
    }
</script>
