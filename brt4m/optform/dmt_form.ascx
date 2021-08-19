<%@ Control Language="C#" ClassName="opt_dmt_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";

    protected string tfzy_country = "", tfzy_end_code = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";

        tfzy_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            tfzy_end_code = Util.Option(conn, "SELECT chrelno, chrelname FROM relation where ChRelType = 'ENDCODE' ORDER BY sortfld", "{chrelno}", "{chrelname}");
        }

        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr id=tr_opt_show style="display:none">			
		<td class=lightbluetable align=right >爭救案案件編號：</td>
		<td class=whitetablebg align=left colspan=7>
            <input type="text" id="opt_no" name="opt_no" class="Lock">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>區所案件編號：</td>
		<td class=whitetablebg colspan=3 id=DelayCase>
			<INPUT TYPE=text id=Branch NAME=Branch SIZE=1 MAXLENGTH=1 class="Lock">-<INPUT TYPE=text id=Bseq NAME=Bseq SIZE=5 MAXLENGTH=5 class="Lock">-<INPUT TYPE=text id=Bseq1 NAME=Bseq1 SIZE=1 MAXLENGTH=1 class="Lock">
		</td>
		<td class=lightbluetable align=right>母案本所編號：</td>
		<td class=whitetablebg colspan=3 >
			<INPUT TYPE=text id="tfzd_ref_no" NAME="tfzd_ref_no" class="QLock" SIZE=5 MAXLENGTH=5>-<INPUT TYPE=text id="tfzd_ref_no1" NAME="tfzd_ref_no1" value="_" SIZE=1 MAXLENGTH=1 class="QLock">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>商標種類：</td>
		<td class=whitetablebg colspan=7>
			<input type=radio name=tfzy_S_Mark value="" class="QLock" checked>商標
            <input type=radio name=tfzy_S_Mark value="S" class="QLock">92年修正前服務標章
            <input type=radio name=tfzy_S_Mark value="N" class="QLock">團體商標
            <input type=radio name=tfzy_S_Mark value="M" class="QLock">團體標章
            <input type=radio name=tfzy_S_Mark value="L" class="QLock">證明標章
			<input type="hidden" id="tfzd_S_Mark" name="tfzd_S_Mark">
		</TD>
	</tr>		
	<tr>
		<td class=lightbluetable align=right>正聯防：</td>
		<td class=whitetablebg colspan=7>
            <SELECT id=tfzy_Pul name=tfzy_Pul class="QLock">
				<option value="">正商標</option>
				<option value="1">聯合商標</option>
				<option value="2">防護商標</option>
            </SELECT>
			<input type="hidden" Name=tfzd_Pul>
		</TD>
	</tr>		
	<tr style="display:none" id="tfzd_Smark">
		<td class=lightbluetable align=right>正商標號數：</td>
		<td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_Tcn_ref class="QLock" SIZE=7 alt="『正商標號數』"  MAXLENGTH="7" ></TD>
		<td class=lightbluetable align=right>正商標類別：</td>
		<td class=whitetablebg colspan=3><input TYPE=text NAME=tfzd_Tcn_Class class="QLock" SIZE=20 alt="『正商標類別』"  MAXLENGTH="20" ></td>
	</tr>
	<tr style="display:none" id="tfzd_Smark1">
		<td class=lightbluetable align=right>正商標名稱：</td>
		<td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_Tcn_name class="QLock" alt="『正商標名稱』" SIZE="20" MAXLENGTH="100" ></TD>
		<td class=lightbluetable align=right>正商標種類：</td>
		<td class=whitetablebg colspan=3>
            <select NAME=tfzd_Tcn_mark id=tfzd_Tcn_mark class="QLock">
			    <option>請選擇</option>
			    <option value="T">商標</option>
			    <option value="S">標章</option>
            </select>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>申請號數：</td>
		<td class=whitetablebg colspan=3><INPUT TYPE=text id=tfzd_apply_no NAME=tfzd_apply_no class="QLock" SIZE=20 alt="『申請號數』" MAXLENGTH="20"></TD>
		<td class=lightbluetable align=right>註冊號數：</td>
		<td class=whitetablebg colspan=3><input TYPE=text id=tfzd_issue_no NAME=tfzd_issue_no class="QLock" SIZE=20 alt="『註冊號數』" MAXLENGTH="20"></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>商標名稱：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text id=tfzd_Appl_name NAME=tfzd_Appl_name class="QLock" alt="『商標名稱』" SIZE="60" MAXLENGTH="100"></TD>
	</tr>
	<tr style="display:" id=fileupload>
		<td class=lightbluetable align=right>商標圖樣：</td>	
		<td class=whitetablebg colspan=7>	
			 <a id="draw_icon" style="display:none" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a>
			<input TYPE="hidden" id="file" name="file">
			<input TYPE="text" name="Draw_file" id="tfz1_Draw_file" SIZE="50" maxlength="50" class="QLock">
		</TD>
	</tr>	
	<tr>
		<td class=lightbluetable align=right>聲明不專用：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text id=tfzd_Oappl_name NAME=tfzd_Oappl_name class="QLock" alt="『不單獨主張專用』" SIZE="60" MAXLENGTH="100"></TD>
	</tr>			
	<tr>
		<td class=lightbluetable align=right>圖樣中文部份：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text id=tfzd_Cappl_name NAME=tfzd_Cappl_name class="QLock" alt="『圖樣中文』" SIZE="60" MAXLENGTH="100"></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖樣外文部份：</td>
		<td class=whitetablebg colspan=7>
		外文：<INPUT TYPE=text NAME=tfzd_Eappl_name id=tfzd_Eappl_name class="QLock" alt="『圖樣外文』" SIZE="60" MAXLENGTH="100" ><br>
		中文字義：<input type=text name=tfzd_eappl_name1 id=tfzd_eappl_name1 class="QLock" alt="『中文字義』" SIZE="60" MAXLENGTH="100"  ><br>
		讀音：<input type=text name=tfzd_eappl_name2 id=tfzd_eappl_name2 class="QLock" alt="『讀音』" SIZE="30" MAXLENGTH="100"  >　
		語文別：<select NAME="tfzy_Zname_type" id="tfzy_Zname_type" class="QLock"><%#tfzy_country%></select>
		<input type="hidden" name="tfzd_Zname_type" id="tfzd_Zname_type">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖形描述：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text id=tfzd_Draw NAME=tfzd_Draw class="QLock" alt="『圖形描述』" SIZE="50" MAXLENGTH="50"  ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>記號說明：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text id=tfzd_Symbol NAME=tfzd_Symbol class="QLock" alt="『記號說明』" SIZE="50" MAXLENGTH="50"  ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖樣顏色：</td>
		<td class=whitetablebg colspan=7>
            <INPUT TYPE=radio NAME=tfzy_color class="QLock" value="B">墨色
            <INPUT TYPE=radio NAME=tfzy_color class="QLock" value="C">彩色
            <INPUT TYPE=radio NAME=tfzy_color class="QLock" value="">無
		    <input type="hidden" name="tfzd_color">
		</td>
	</tr>

	<tr>
		<td class="lightbluetable" align="right">優先權申請日：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="pfzd_prior_date" NAME="pfzd_prior_date" class="QLock" SIZE="10"></TD>
		<td class="lightbluetable" align="right">優先權首次申請國家：</td>
		<td class="whitetablebg" colspan="3">
            <select NAME="tfzy_prior_country" id="tfzy_prior_country" class="QLock"><%#tfzy_country%></select>
		    <input type="hidden" name="tfzd_prior_country">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>優先權申請案號：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_prior_no ID=tfzd_prior_no size="10" maxlength="20" class="QLock"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_apply_date" NAME="tfzd_apply_date" class="QLock" SIZE="10"></TD>
		<td class="lightbluetable" align="right">註冊日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_issue_date" NAME="tfzd_issue_date" class="QLock" SIZE="10"></TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">公告日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_open_date" NAME="tfzd_open_date" class="QLock" SIZE="10"></TD>
		<td class="lightbluetable" align="right">核駁號：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_rej_no" NAME="tfzd_rej_no" class="QLock" SIZE="10" alt="『核駁號』"  MAXLENGTH="20" ></TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">結案日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_end_date" NAME="tfzd_end_date" class="QLock" SIZE="10"></TD>
		<td class="lightbluetable" align="right">結案代碼：</td>
		<td class="whitetablebg" colspan="3">
            <select id="tfzy_end_code" NAME="tfzy_end_code" class="QLock"><%#tfzy_end_code%></select>
		    <input type="hidden" name="tfzd_End_Code">
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">專用期限：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_dmt_term1" NAME="tfzd_dmt_term1" class="QLock" SIZE="10">～<input TYPE="text" id="tfzd_dmt_term2" NAME="tfzd_dmt_term2" class="QLock" SIZE="10"></TD>
		<td class="lightbluetable" align="right">延展次數：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" id="tfzd_renewal" NAME="tfzd_renewal" class="QLock" SIZE="2"></TD>
	</tr>
    <tr>
	    <td class=whitetablebg colspan=8>
	        <TABLE border=0 id="goodllist" class="bluetable" cellspacing=1 cellpadding=2 width="100%">
                <thead>
	                <tr>
		                <td class=lightbluetable align=right>類別：</td>		
		                <td class=whitetablebg colspan=7>
                            共<input type="text" class="QLock" id=tfzr_class_count name=tfzr_class_count size=2 onchange="dmt_form.Add_button(this.value)">類
                            <input type="text" id=tfzr_class name=tfzr_class class="QLock">
		                </td>
	                </tr>
                </thead>
                <tfoot style="display:none;">
	                <tr>
		                <td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別，並以逗號分開(例如：1,5,32)。或輸入類別範圍，並以  -  (半形) 分開(例如：8-16)。也可複項組合(例如：3,5,13-32,35)">
                            類別##：
		                </td>
		                <td class="whitetablebg" colspan="7"><!--2013/1/22玉雀告知不顯示商標法施行細則第13條-->
                            第<INPUT type="text" class="QLock" id=class1_## name=class1_## size=2 maxlength=2 onchange="count_kind(this.value,1)">類
		                </td>
	                </tr>
	                <tr>
		                <td class="lightbluetable" align="right" width="18%">商品名稱##：</td>
		                <td class="whitetablebg" colspan="7">
                            <textarea id="good_name1_##" name="good_name1_##" ROWS="10" COLS="75" class="QLock"></textarea><br>
                            共<input type="text" id=good_count1_## name=good_count1_## size=2 class="QLock">項
		                </td>
	                </tr>
	                <tr>
		                <td class="lightbluetable" align="right">商品群組代碼##：</td>
		                <td class="whitetablebg" colspan="7">
                            <textarea id=grp_code1_## name=grp_code1_## ROWS="1" COLS="50" class="QLock"></textarea>(跨群組請以全形「、」作分隔)
                        </td>
	                </tr>
                </tfoot>
                <tbody></tbody>
	        </table>
	    </td>
	</tr>
</table>

<script language="javascript" type="text/javascript">
    var dmt_form = {};
    dmt_form.init = function () {
        var jOpt = br_opt.opt[0];
        $("#opt_no").val(jOpt.opt_no);
        $("#Branch").val(jOpt.branch);
        $("#Bseq").val(jOpt.bseq);
        $("#Bseq1").val(jOpt.bseq1);
        $("#tfzd_ref_no").val(jOpt.ref_no);
        $("#tfzd_ref_no1").val(jOpt.ref_no1);
        $("input[name='tfzy_S_Mark'][value='" + jOpt.s_mark + "']").prop("checked", true);
        $("#tfzd_S_Mark").val(jOpt.s_mark);
        $("#tfzy_Pul").val(jOpt.pul);
        $("#tfzy_Zname_type").val(jOpt.zname_type);
        $("#tfzd_Zname_type").val(jOpt.zname_type);
        $("input[name='tfzy_color'][value='" + jOpt.color + "']").prop("checked", true);
        $("#tfzy_prior_country").val(jOpt.prior_country);
        $("#tfzy_end_code").val(jOpt.end_code);

        $("#tfzd_apply_no").val(jOpt.apply_no);
        $("#tfzd_issue_no").val(jOpt.issue_no);
        $("#tfzd_Appl_name").val(jOpt.appl_name);
        if (jOpt.draw_file != "") $("#draw_icon").attr("href", jOpt.drfile).show();
        $("#file").val(jOpt.draw_file);
        $("#tfz1_Draw_file").val(jOpt.draw_file);
        $("#tfzd_Oappl_name").val(jOpt.oappl_name);
        $("#tfzd_Cappl_name").val(jOpt.cappl_name);
        $("#tfzd_Eappl_name").val(jOpt.eappl_name);
        $("#tfzd_eappl_name1").val(jOpt.eappl_name1);
        $("#tfzd_eappl_name2").val(jOpt.eappl_name2);
        $("#tfzd_Zname_type").val(jOpt.zname_type);
        $("#tfzd_Draw").val(jOpt.draw);
        $("#tfzd_Symbol").val(jOpt.symbol);
        $("#pfzd_prior_date").val(dateReviver(jOpt.prior_date, "yyyy/M/d"));
        $("#tfzd_prior_no").val(jOpt.prior_no);
        $("#tfzd_apply_date").val(dateReviver(jOpt.apply_date, "yyyy/M/d"));
        $("#tfzd_issue_date").val(dateReviver(jOpt.issue_date, "yyyy/M/d"));
        $("#tfzd_open_date").val(dateReviver(jOpt.open_date, "yyyy/M/d"));
        $("#tfzd_rej_no").val(jOpt.rej_no);
        $("#tfzd_end_date").val(dateReviver(jOpt.end_date, "yyyy/M/d"));
        $("#tfzd_dmt_term1").val(jOpt.dmt_term1);
        $("#tfzd_dmt_term2").val(jOpt.dmt_term2);
        $("#tfzd_renewal").val(jOpt.renewal);

        //商品
        var good = br_opt.casegood;
        var classCount = good.length;
        if (classCount == 0) classCount = 1;//至少有1筆
        $("#tfzr_class_count").val(good.length == 0 ? "" : classCount);//共N類
        $("#goodllist>tbody").empty();

        dmt_form.Add_button(classCount);//產生類別清單
        if (good.length!=0){
            $.each(good, function (i, item) {
                var nRow = i + 1;
                $("#class1_" + nRow).val(item.class);
                $("#good_count1_" + nRow).val(item.dmt_goodcount);
                $("#grp_code1_" + nRow).val(item.dmt_grp_code);
                $("#good_name1_" + nRow).val(item.dmt_goodname);
            });
        }
        //類別串接
        $("#tfzr_class").val($("#goodllist>tbody input[id^='class1_']").map(function () { return $(this).val(); }).get().join(','));

        //$("#tr_opt_show").showFor("<%#prgid%>" == "opt31" || "<%#prgid%>" == "opt31_1");//承辦/結辦作業要顯示 爭救案件編號
    }
    
    dmt_form.Add_button = function (classCount) {
        for (var nRow = 1; nRow <= classCount; nRow++) {
            //複製一筆
            $("#goodllist>tfoot").each(function (i) {
                var strLine1 = $(this).html().replace(/##/g, nRow);
                $("#goodllist>tbody").append(strLine1);
            });
        }
    }
</script>
