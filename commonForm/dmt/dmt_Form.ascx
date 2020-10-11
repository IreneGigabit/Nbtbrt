<%@ Control Language="C#" ClassName="dmt_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfz1_agt_no = "", tfz_country = "", tfzy_end_code = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        if (prgid.ToLower() == "brt51") {//程序客收確認
            Lock["brt51"] = "Lock";
            Hide["brt51"] = "Hide";
        } else {
            Lock["brt51"] = "";
            Lock["brt51"] = "";
        }

        //代理人
        tfz1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        //語文別/國家
        tfz_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        //結案代碼
        tfzy_end_code = Sys.getEndCode().Option("{chrelno}", "{chrelname}");
    }
</script>

<%=Sys.GetAscxPath(this)%>
<input type="hidden" name="branch" id="branch" value=<%=Session["seBranch"]%>>
<input type="hidden" name="tfy_end_flag" id="tfy_end_flag"><!--結案註記-->
<input type="hidden" name="tfy_end_type" id="tfy_end_type"><!--結案原因-->
<input type="hidden" name="tfy_end_remark" id="tfy_end_remark"><!--結案原因-->
<input type="hidden" name="tfy_back_flag" id="tfy_back_flag"><!--復案註記-->
<input type="hidden" name="tfy_back_remark" id="tfy_back_remark"><!--復案原因-->
<input type="hidden" name="oback_flag" id="oback_flag">
<input type="hidden" name="oend_flag" id="oend_flag">
<input type="hidden" name="todoend_flag" id="todoend_flag" value="N"><!--結案流程進行中，N:無 Y:有-->
<INPUT type="hidden" name=tfzb_seq id=tfzb_seq style=5 MAXLENGTH=5>
<INPUT type="hidden" name=tfzb_seq1 id=tfzb_seq1 SIZE=1 MAXLENGTH=1 value="_">
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <!--2011/1/1結案及復案由營洽自行勾選，全部交辦畫面皆要加畫面欄位，入資料庫值由案件主檔欄位入-->
	<tr>			
	    <td class=lightbluetable align=right>案件種類：</td>
	    <td class=whitetablebg colspan=7>
            <Select id="tfy_case_stat" name="tfy_case_stat" onchange=new_oldcase>
		        <option value="NN">新案</option>
		        <option value="SN">新案(指定編號)</option>
		        <option value="OO">舊案</option>
            </Select>
	    </TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>主案件編號：</td>
		<td class=whitetablebg colspan=3>
            <span id=DelayCase><!--舊案-->
			    <INPUT TYPE=text NAME=old_seq id=old_seq SIZE=5 MAXLENGTH=5 onblur="mainseqChange('old_seq')">-<INPUT TYPE=text NAME=old_seq1 id=old_seq1 SIZE=1 MAXLENGTH=1 value="_" onblur="mainseqChange('old_seq')" style="text-transform:uppercase;">	
			    <INPUT TYPE=button name=btnseq_ok id=btnseq_ok onclick="delayNO reg.old_seq.value,reg.old_seq1.value " value="確定">　<input type=button class="cbutton" name="Query" id="Query" value ="查詢主案件編號" style="width:140" onclick="Queryclick(reg.F_cust_seq.value)">
			    <input type=button class="cbutton" name="Qry_step" id="Qry_step" value ="查詢案件進度" style="width:100" onclick="vbscript:Qstepclick reg.old_seq.value,reg.old_seq1.value">
			    <input type=button class="c1button <%#Hide["brt51"]%>" name="Upd_seq" id="Upd_seq" value ="案件主檔維護" style="width:100" onclick="vbscript:Updseqclick reg.old_seq.value,reg.old_seq1.value">
			    <input type="text" name=keyseq id=keyseq value="N">
            </span>
            <span id=CaseNew><!--新案-->
			    <INPUT TYPE=text NAME=New_seq id=New_seq SIZE=5 MAXLENGTH=5 class="sedit" readonly>-
			    <select name=New_seq1 id=New_seq1 class="<%#Lock["brt51"]%>">
				    <option value="_">一般</option>
				    <option value="Z">Z_雜卷</option>
				    <%if(Session["seBranch"].ToString()=="N")%><option value="M">M_大陸案</option>
			    </select>
            </span>
            <span id=CaseNewAssign><!--新案(指定編號)-->
 			    <INPUT TYPE=text id=New_Ass_seq NAME=New_Ass_seq SIZE=5 MAXLENGTH=5>-<INPUT TYPE=text id=New_Ass_seq1 NAME=New_Ass_seq1 SIZE=1 MAXLENGTH=1 value="" style="text-transform:uppercase;">	
           </span>
		</td>
		<td class=lightbluetable align=right>母案本所編號：</td>
		<td class=whitetablebg colspan=3 >
			<INPUT TYPE=text NAME="tfzd_ref_no" id="tfzd_ref_no" SIZE=5 MAXLENGTH=5>-<INPUT TYPE=text NAME="tfzd_ref_no1" id="tfzd_ref_no1" SIZE=1 MAXLENGTH=1 value="_">
			<INPUT TYPE=button Name="but_ref" id="but_ref" onclick="delayNO1 reg.tfzd_ref_no.value,reg.tfzd_ref_no1.value "  class="bluebutton" value="母案複製">
			<!-- 程序客收移轉舊案要結案 2006/5/26 -->
			<input type=hidden name="endflag51" id="endflag51" value="X">
			<input type=hidden name="end_date51" id="end_date51">
			<input type=hidden name="end_code51" id="end_code51">
			<input type=hidden name="end_type51" id="end_type51">
			<input type=hidden name="end_remark51" id="end_remark51">
			<%if prgid = "Brt51" and request("ar_form")="A8" then%>
				<INPUT TYPE=button Name="but_end" id="but_end" onclick="btnendA8click 'tfzd_ref_no',reg.tfzd_ref_no.value,reg.tfzd_ref_no1.value"  class="redbutton" value="母案結案">
			<%end if%>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" rowspan=2>商標種類：</td>
		<td class="whitetablebg" colspan=7>
            <input type="radio" name="tfzy_S_Mark" value="" onclick="dmt_form.change_mark(0)">商標
            <input type="radio" name="tfzy_S_Mark" value="S" onclick="dmt_form.change_mark(0)">92年修正前服務標章
            <input type="radio" name="tfzy_S_Mark" value="N" onclick="dmt_form.change_mark(0)">團體商標
            <input type="radio" name="tfzy_S_Mark" value="M" onclick="dmt_form.change_mark(0)">團體標章
            <input type="radio" name="tfzy_S_Mark" value="L" onclick="dmt_form.change_mark(0)">證明標章
            <input type="text" id="tfzd_S_Mark" name="tfzd_S_Mark" value="">
		</TD>
	</tr>
	<tr >
		<td class="whitetablebg" colspan=7>
			<input type="radio" name="tfzd_s_mark2" value="A">平面
			<input type="radio" name="tfzd_s_mark2" value="B">立體
			<input type="radio" name="tfzd_s_mark2" value="C">聲音
			<input type="radio" name="tfzd_s_mark2" value="D">顏色
			<input type="radio" name="tfzd_s_mark2" value="E">全像圖
			<input type="radio" name="tfzd_s_mark2" value="F">動態
			<!--input type="radio" name="tfzd_s_mark2" value="G">其他-->
			<input type="radio" name="tfzd_s_mark2" value="H">位置
			<input type="radio" name="tfzd_s_mark2" value="I">氣味
			<input type="radio" name="tfzd_s_mark2" value="J">觸覺
		</TD>
	</tr>	
	<tr>
		<td class="lightbluetable" align="right">客戶卷號：</td>
		<td class="whitetablebg" colspan=7>
			<input type="text" id="tfzd_cust_prod" name="tfzd_cust_prod" size="15">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>正聯防：</td>
		<td class=whitetablebg colspan=7>
            <SELECT NAME=tfzy_Pul id=tfzy_Pul onchange=tfzd_showmark(reg.tfzy_pul.value)>
			<option value="">正商標</option>
			<option value="1">聯合商標</option>
			<option value="2">防護商標</option>
            </SELECT>
			<input type="hidden" Name=tfzd_Pul id=tfzd_Pul>
		</TD>
	</tr>
	<tr style="display:none" id="tfzd_Smark">
		<td class=lightbluetable align=right>正商標號數：</td>
		<td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_Tcn_ref id=tfzd_Tcn_ref SIZE=7 alt="『正商標號數』"  MAXLENGTH="7" onblur="fDataLen(this)"></TD>
		<td class=lightbluetable align=right>正商標類別：</td>
		<td class=whitetablebg colspan=3><input TYPE=text NAME=tfzd_Tcn_Class id=tfzd_Tcn_Class SIZE=20 alt="『正商標類別』"  MAXLENGTH="20" onblur="fDataLen(this)"></td>
	</tr>
	<tr style="display:none" id="tfzd_Smark1">
		<td class=lightbluetable align=right>正商標名稱：</td>
		<td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_Tcn_name id=tfzd_Tcn_name alt="『正商標名稱』" SIZE="20" MAXLENGTH="100" onblur="fDataLen(this)"></TD>
		<td class=lightbluetable align=right>正商標種類：</td>
		<td class=whitetablebg colspan=3>
            <select NAME=tfzd_Tcn_mark id=tfzd_Tcn_mark >
			<option value="">請選擇</option>
			<option value="T">商標</option>
			<option value="S">標章</option>
            </select>
        </td>
	</tr>
    <tr>
	    <td class=lightbluetable align=right>申請號數：</td>
	    <td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_apply_no id=tfzd_apply_no SIZE=20 alt="『申請號數』" MAXLENGTH="20" onblur="chk_dmt_applyno(this,9)"><input type="hidden" name=O_apply_no id=O_apply_no></TD>
	    <td class=lightbluetable align=right>註冊號數：</td>
	    <td class=whitetablebg colspan=3><input TYPE=text NAME=tfzd_issue_no id=tfzd_issue_no SIZE=20 alt="『註冊號數』" MAXLENGTH="20" onblur="chk_dmt_issueno(this,8)" ><input type="hidden" name=O_issue_no id=O_issue_no></td>
    </tr>
    <tr>
	    <td class=lightbluetable align=right>商標名稱：</td>
	    <td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Appl_name id=tfzd_Appl_name alt="『商標名稱』" SIZE="60" MAXLENGTH="100" onblur="fDataLen(this)"></TD>
    </tr>
	<tr id=fileupload>
		<td class=lightbluetable align=right>商標圖樣：</td>	
		<td class=whitetablebg colspan=7>	
			<input TYPE="hidden" id="file" name="file">
			<input type="button" class="cbutton" id="butUpload1" name="butUpload1"  value="商標圖檔上傳" onclick="dmt_form.UploadAttach_photo()" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="dmt_form.DelAttach_photo()" >
            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="dmt_form.PreviewAttach_photo()" >
	        <input type="hidden" name="draw_attach_file" id="draw_attach_file">
		</TD>
	</tr>	
	<tr>
		<td class=lightbluetable align=right>聲明不專用：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Oappl_name id=tfzd_Oappl_name alt="『不單獨主張專用』" SIZE="60" MAXLENGTH="100" onblur="fDataLen(this)" ></TD>
	</tr>			
	<tr>
		<td class=lightbluetable align=right>圖樣中文部份：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Cappl_name id=tfzd_Cappl_name alt="『圖樣中文』" SIZE="60" MAXLENGTH="100" onblur="fDataLen(this)" ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖樣外文部份：</td>
		<td class=whitetablebg colspan=7>
			外文：<INPUT TYPE=text NAME=tfzd_Eappl_name id=tfzd_Eappl_name alt="『圖樣外文』" SIZE="60" MAXLENGTH="100" onblur="fDataLen(this)" ><br>
			中文字義：<input type=text name=tfzd_eappl_name1 id=tfzd_eappl_name1 alt="『中文字義』" SIZE="60" MAXLENGTH="100" onblur="fDataLen(this)" ><br>
			讀音：<input type=text name=tfzd_eappl_name2 id=tfzd_eappl_name2 alt="『讀音』" SIZE="30" MAXLENGTH="100" onblur="fDataLen(this)" >　
			語文別：<select NAME="tfzy_Zname_type" id="tfzy_Zname_type"><%#tfz_country%></select>
			<input type="hidden" name="tfzd_Zname_type" id="tfzd_Zname_type">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖形描述：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Draw id=tfzd_Draw alt="『圖形描述』" SIZE="50" MAXLENGTH="50" onblur="fDataLen(this)" ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>記號說明：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Symbol id=tfzd_Symbol alt="『記號說明』" SIZE="50" MAXLENGTH="50" onblur="fDataLen(this)" ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖樣顏色：</td>
		<td class=whitetablebg colspan=7>
            <INPUT TYPE=radio NAME=tfzy_color ID=tfzy_colorB value="B">墨色
            <INPUT TYPE=radio NAME=tfzy_color ID=tfzy_colorC value="C">彩色
            <INPUT TYPE=radio NAME=tfzy_color ID=tfzy_colorX value="">無
			<input type="hidden" name="tfzd_color" id="tfzd_color">
		</td>
	</tr>
    <tr>
		<td class="lightbluetable" align="right">優先權申請日：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="pfzd_prior_date" id="pfzd_prior_date" SIZE="10" class="dateField"></TD>
		<td class="lightbluetable" align="right">優先權首次申請國家：</td>
		<td class="whitetablebg" colspan="3">
            <select NAME="tfzy_prior_country" id="tfzy_prior_country"><%#tfz_country%></select>
			<input type="hidden" name="tfzd_prior_country" id="tfzd_prior_country">
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right>優先權申請案號：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_prior_no ID=tfzd_prior_no value="" size="10" maxlength="20"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_apply_date"  id="tfzd_apply_date" SIZE="10" class="dateField"></TD>
		<td class="lightbluetable" align="right">註冊日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_issue_date" id="tfzd_issue_date" SIZE="10" class="dateField"></TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">公告日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_open_date" id="tfzd_open_date" SIZE="10" class="dateField"></TD>
		<td class="lightbluetable" align="right">核駁號：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="text" NAME="tfzd_rej_no" id="tfzd_rej_no" SIZE="10" alt="『核駁號』"  MAXLENGTH="20" onblur="chk_dmt_rejno(this,7)">
            <input type="hidden" name=O_rej_no id=O_rej_no>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">結案日期：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_end_date" id="tfzd_end_date" SIZE="10" class="dateField"></TD>
		<td class="lightbluetable" align="right">結案代碼：</td>
		<td class="whitetablebg" colspan="3">
            <select NAME="tfzy_end_code" id="tfzy_end_code"><%#tfzy_end_code%></select>
			<input type="hidden" name="tfzd_End_Code" id="tfzd_End_Code">
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">專用期限：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_dmt_term1" id="tfzd_dmt_term1" SIZE="10" class="dateField"></TD>
		<td class="lightbluetable" align="right">延展次數：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_renewal" id="tfzd_renewal" SIZE="2"></TD>
	</tr>
	<tr>
		<td colspan=8>
			<TABLE id=tabbr1 name=tabbr1 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
            <thead>
			    <tr>	
				    <td class="lightbluetable" align="right" >類別種類：</td>
				    <td class="whitetablebg" colspan="7" >
					    <input type="radio" id="tfzr_class_typeI" name=tfzr_class_type value="int">國際分類
					    <input type="radio" id="tfzr_class_typeO" name=tfzr_class_type value="old">舊類
				    </td>
			    </tr>
			    <tr>
				    <td class=lightbluetable align=right>類別：</td>		
				    <td class=whitetablebg colspan=7>共<input type="text" id=tfzr_class_count name=tfzr_class_count size=2 onchange="dmt_form.Add_class(this.value)">類
                        <input type="text" name=tfzr_class id=tfzr_class style="width:70%" readonly>
					    <input type=hidden name=num1 id=num1 value="0"><!--畫面上有幾筆-->
				        <input type=hidden name=ctrlnum1 id=ctrlnum1 value="0">
					    <input type=hidden name=ctrlcount1 id=ctrlcount1 value="">
				    </td>
			    </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="class_template"><!--類別樣板-->
		        <tr class="tr_class_##">
				    <td class="lightbluetable" align="right" style="cursor:hand" title="請輸入類別，並以逗號分開(例如：1,5,32)。或輸入類別範圍，並以  -  (半形) 分開(例如：8-16)。也可複項組合(例如：3,5,13-32,35)">類別##：</td>		
				    <td class="whitetablebg" colspan="7"><!--2013/1/22玉雀告知不顯示商標法施行細則第13條-->第<INPUT type="text" id=class1_## name=class1_## size=3 maxlength=3 onchange="dmt_form.count_kind('##')">類</td>
			    </tr>
			    <tr class="tr_class_##" style="height:107.6pt">
				    <td class="lightbluetable" align="right" width="18%">商品名稱##：</td>			
				    <td class="whitetablebg" colspan="7">
                        <textarea id="good_name1_##" NAME="good_name1_##" ROWS="10" COLS="75"  onchange="dmt_form.good_name_count('##')"></textarea>
                        <br>共<input type="text" id=good_count1_## name=good_count1_## size=2>項
				    </td>
			    </tr>
		        <tr class="tr_class_##">
				    <td class="lightbluetable" align="right">商品群組代碼##：</td>
				    <td class="whitetablebg" colspan="7"><textarea id=grp_code1_## NAME=grp_code1_## ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
				    <input type="hidden" id="color_##" name="color_##" value="">
			    </tr>
            </script>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan=8>
			<input type=hidden id=shownum_dmt name=shownum_dmt value="0">
			<TABLE id=tabshow_dmt border=1 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
                <thead>
			    <TR class=whitetablebg align=center>
				    <TD colspan=3 >
				        <input type=button value ="增加一筆展覽會優先權" class="cbutton" id=show_Add_button name=show_Add_button_FA1 onclick="dmt_form.add_show()">			
				        <input type=button value ="減少一筆展覽會優先權" class="cbutton" id=show_Del_button name=show_Del_button_FA1 onclick="dmt_form.del_show()">
				    </TD>
			    </TR>
			    <tr>
				    <td class="lightbluetable" align="center" ></td>	
				    <td class="lightbluetable" align="center" >展覽會優先權日</td>
				    <td class="lightbluetable" align="center" >展覽會名稱</td>	
			    </tr>
                </thead>
                <tbody></tbody>
                <script type="text/html" id="show_template"><!--展覽會優先權樣板-->
	                <tr id=tr_show_##>
		                <td class=whitetablebg align=center>
                            <input type=text id='shownum_##' name='shownum_##' class=SEdit readonly size=2 value='##.'>
                            <input type=hidden id='show_sqlno_##' name='show_sqlno_##'>
		                </td>
		                <td class=whitetablebg align=center>
		                    <input type=text size=10 maxlength=10 id='show_date_##' name='show_date_##' onblur="dmt_form.chk_showdate('##')" class="dateField" <%=Qclass%> />
		                </td>
		                <td class=whitetablebg align=center>
		                    <input type=text id='show_name_##' name='show_name_##' size=50 maxlength=100 <%=Qclass%> />
		                </td>
	                </tr>
                </script>
			</table>
		</td>	
	</tr>
</table>


<script language="javascript" type="text/javascript">
    var dmt_form = {};
    dmt_form.init = function () {
    }

    //新案(指定編號)
    dmt_form.chkseq = function () {
        if ($("#tfy_case_stat").val()!="SN") return false;
        //chk案件主檔需有資料
        if ($("#New_Ass_seq").val()!="") {
            var url=getRootPath() + "/brt1m/chk_dmt.aspx?p1=Y&p2=A&seq=" +$("#New_Ass_seq").val()+ "&seq1=" +$("#New_Ass_seq1").val();
            scriptByGet("chk案件主檔",url);
        }
        $("#dseqa1").val($("#New_Ass_seq").val());
        $("#dseq1a1").val($("#New_Ass_seq1").val());
        $("#dseqb1").val($("#New_Ass_seq").val());
        $("#dseq1b1").val($("#New_Ass_seq1").val());
    }
    //新案-副號選擇
    $("#New_seq1").change(function () {
        $("#dseqa1").val($("#New_seq").val());
        $("#dseq1a1").val($("#New_seq1").val());
        $("#dseqb1").val($("#New_seq").val());
        $("#dseq1b1").val($("#New_seq1").val());
    });
    //新案指定編號-副號
    $("#New_ass_seq1").blur(function () {
        var this_val=$(this).val();
        if(this_val=="") return false;
        if($("#tfy_case_stat").val()=="SN"){
            if(this_val=="_"||this_val=="Z"||this_val=="M"){
                alert("案件副碼不可為 _、Z、M");
                $(this).focus();
                return false;
            }
        }
        dmt_form.chkseq();
    });
    //爭救案-異議、評定、廢止增加新案指定編號功能，輸入副號後檢查
    dmt_form.New_ass_seqB_blur=function(pfldname) {
        if($("#"+pfldname+"_New_ass_seq").val()=="") return false;
        if($("#"+pfldname+"_New_ass_seq1").val()=="") return false;
        $("#"+pfldname+"_New_ass_seq1").val($("#"+pfldname+"_New_ass_seq1").val().toUpperCase());
        if($("#"+pfldname+"_case_stat").val()=="SN"){
            if($("#"+pfldname+"_New_ass_seq1").val()=="_"||$("#"+pfldname+"_New_ass_seq1").val()=="Z"||$("#"+pfldname+"_New_ass_seq1").val()=="M"){
                alert("案件副碼不可為 _、Z、M");
                $("#"+pfldname+"_New_ass_seq1").val().focus();
                return false;
            }
        }
        dmt_form.chkseqB(pfldname);
    }
    dmt_form.chkseqB = function(pfldname) {
        if ($("#"+pfldname+"_case_stat").val()!="SN") return false;
        //chk案件主檔需有資料
        if ($("#"+pfldname+"_New_ass_seq").val()!="") {
            var pseq=$("#"+pfldname+"_New_ass_seq").val();
            var pseq1=$("#"+pfldname+"_New_ass_seq1").val();
            var url=getRootPath() + "/brt1m/chk_dmt.aspx?fldname="+pfldname+"&p1=Y&p2=A&seq=" +pseq+ "&seq1=" +pseq1;
            scriptByGet("chkB案件主檔",url);
        }
    }

    /*
    //查詢主案件編號
    dmt_form.Queryclick = function(cust_seq) {
        //***todo
        window.open("brta21Query.asp?cust_seq="+cust_seq ,"myWindowOne", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
    dmt_form.mainseqChange = function(fld1) {
        $("#keyseq").val("N");
        $("#btnseq_ok").prop("disabled",false);
    }
    //母案結案
    dmt_form.btnendA8click = function(fld,value1,value2) {
        if (value1==""){
            alert("請先輸入本所編號!!!");
            $("#"+fld).focus();
            return false;
        }else{
            if(fld.indexOf("dmseq")>-1){
                from_fld=fld.substr(5);
            }else{
                from_fld="";
            }
            //***todo
            window.open("..\brt5m\brt15ShowFP.asp?seq="&value1&"&seq1="&value2 & "&from_fld=" & from_fld & "&submittask=Q&prgid=Brt51&end_type=012","", "width=900px, height=650px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
        }
    }
    //案件進度查詢
    dmt_form.Qstepclick = function(pseq,pseq1) {
        if (pseq!=""&&pseq1!=""){
        //***todo
            window.open("/btbrt/brtam/brta61Edit.asp?submitTask=Q&qtype=A&prgid="+main.prgid+"&closewin=Y&winact=1&aseq=" &pseq& "&aseq1=" &pseq1,"myWindowOne", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
        }else{
            alert("請先輸入本所編號再執行維護功能!!!");
            return false;
       }
    }
    //案件主檔維護
    dmt_form.Updseqclick = function(pseq,pseq1) {
        if (pseq!=""&&pseq1!=""){
            //***todo
            window.open("/btbrt/brt5m/brt15ShowFP.asp?seq="&pseq&"&seq1="&pseq1&"&submittask=U&prgid=Brt51&closewin=Y","myWindowOneu", "width=900 height=700 top=10 left=10 toolbar=no menubar=no, location=no, directories=no, status=no,resizable=no, scrollbars=yes");
        }else{
            alert("請先輸入本所編號再執行維護功能!!!");
            return false;
        }
    }
*/
//商標種類(x:0=案件主檔→交辦內容,x:1=交辦內容→案件主檔)
dmt_form.change_mark = function (x) {
    if(x==1){
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr3_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr2_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr21_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr4_S_mark']:checked").val()+"']").prop("checked",true);
        $("#tfzy_Pul").val("2");
        dmt_form.tfzd_showmark($("#tfzy_Pul").val());
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr1_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr3_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='frf_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fbf_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr_S_mark']:checked").val()+"']").prop("checked",true);
        $("input[name='tfzy_S_Mark'][value='"+ $("input[name='fr11_S_mark']:checked").val()+"']").prop("checked",true);
    }else{
        $("input[name='fr3_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='fr2_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='fr1_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='fr4_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='frf_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='fbf_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='fr_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
        $("input[name='fr11_S_Mark'][value='"+ $("input[name='tfzy_S_Mark']:checked").val()+"']").prop("checked",true);
    }

    var smark_val=$("input[name='tfzy_S_Mark']:checked").val();
    if(smark_val=="S"){
        $("#s_marka1").val("92年修正前服務標章");
        $("#s_markb1").val("92年修正前服務標章");
    }else if(smark_val=="N"){
        $("#s_marka1").val("團體商標");
        $("#s_markb1").val("團體商標");
    }else if(smark_val=="M"){
        $("#s_marka1").val("團體標章");
        $("#s_markb1").val("團體標章");
    }else if(smark_val=="L"){
        $("#s_marka1").val("證明標章");
        $("#s_markb1").val("證明標章");
    }else{
        $("#s_marka1").val("商標");
        $("#s_markb1").val("商標");
    }
};

    //註冊號數帶資料到交辦內容
    $("#tfzd_issue_no").blur(function () {
        $("#O_issue_no").val($(this).val());
        $("#fr3_issue_no").val($(this).val());
        $("#new_no21").val($(this).val());
        $("#fr4_issue_no").val($(this).val());
        $("#issue_nob1").val($(this).val());
        $("#fr1_issue_no").val($(this).val());
        $("#fr2_issue_no").val($(this).val());
        $("#fr_issue_no").val($(this).val());
    });

    //商標名稱帶資料到交辦內容
    $("#tfzd_Appl_name").blur(function () {
        if (check_CustWatch("appl_name",$(this).val())==true){
            return false;
        }
        $("#ncname111").val($(this).val());
        $("#ncname121").val($(this).val());
        $("#fr3_appl_name").val($(this).val());
        $("#fr4_appl_name").val($(this).val());
        $("#appl_namea1").val($(this).val());
        $("#appl_nameb1").val($(this).val());
        $("#fr1_appl_name").val($(this).val());
        $("#fr2_appl_name").val($(this).val());
        $("#frf_Appl_name").val($(this).val());
        $("#fr_Appl_name").val($(this).val());
        $("#fr_Appl_name").val($(this).val());
    });

    //申請號數帶資料到交辦內容
    $("#tfzd_apply_no").blur(function () {
        $("#O_apply_no").val($(this).val());
        $("#fr_apply_no").val($(this).val());
        $("#new_no11").val($(this).val());
        $("#apply_noa1").val($(this).val());
        $("#fr1_apply_no").val($(this).val());
        $("#fbf_no").val($(this).val());
    });

    //核騻號帶資料
    $("#tfzd_rej_no").blur(function () {
        $("#O_rej_no").val($(this).val());
    });

    //*****依商品名稱計算類別
    dmt_form.good_name_count = function (nRow) {
        var MyString = $("#good_name1_" + nRow).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        $("#good_count1_" + nRow).val("");
        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#good_name1_" + nRow).val(MyString);
            var aKind = myarray.length;//共幾類
            alert("商品內容共" + aKind + "項");
            $("#good_count1_" + nRow).val(aKind);

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }

    //共N類
    dmt_form.Add_class = function (classCount) {
        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num1 = CInt($("#num1").val());//目前畫面上有幾筆
        if (doCount > num1) {//要加
            for (var nRow = num1; nRow < doCount ; nRow++) {
                var copyStr = $("#class_template").text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbr1 tbody").append(copyStr);
                $("#num1").val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num1; nRow > doCount ; nRow--) {
                $('.tr_class_' + nRow).remove();
                $("#num1").val(nRow - 1);
            }
        }
    }

    //檢查類別範圍0~45
    dmt_form.checkclass = function (xclass) {
        if (CInt(xclass) < 0 || CInt(xclass) > 45) {
            alert("商品類別需介於1~45之間,請重新輸入。");
            return false;
        }
    }

    //類別串接
    dmt_form.count_kind = function (nRow) {
        if ($("#class1_" + nRow).val() != "") {
            if (IsNumeric($("#class1_" + nRow).val())) {
                var x = ("000" + $("#class1_" + nRow).val()).Right(3);//補0
                $("#class1_" + nRow).val(x);
                dmt_form.checkclass(x);
            } else {
                alert("商品類別請輸入數值!!!");
                $("#class1_" + nRow).val("");
            }
        }

        $("#tfz1_class").val($("#tabbr1>tbody input[id^='class1_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        }).get().join(','));
    }

    //*****展覽優先權抓資料
    dmt_form.getshow = function (pfld,xtype) {
        $("#tabshow_dmt tbody").empty();

        var jurl="";
        if(xtype=="case"){//接洽案件
            var pin_no=$("#in_no").val();
            jurl=getRootPath() + "/ajax/json_get_dmt_show.aspx?datasource=case&in_no=" + pin_no + "&case_sqlno=0";
        }else{
            var pseq="",pseq1="";
            if(xtype=="dmt"){//舊案抓取
                pseq=$("#old_seq").val();
                pseq1=$("#old_seq1").val();
            }else if(xtype=="dmt_mseq"){//母案複製
                pseq=$("#tfzd_ref_no").val();
                pseq1=$("#tfzd_ref_no1").val();
            }
            if(pseq==""){
                alert("無案件編號，系統無法抓取展覽優先權資料，請通知資訊部！");
                return false;
            }
            jurl=getRootPath() + "/ajax/json_get_dmt_show.aspx?datasource=dmt&seq=" + pseq + "&seq1=" + pseq1;
        }

        $.ajax({
            type: "get",
            url: jurl,
            async: false,
            cache: false,
            success: function (json) {
                var jShow = $.parseJSON(json);
                if (jShow.length != 0) {
                    $.each(jShow.case_show, function (i, item) {
                        dmt_form.add_show();//展覽優先權增加一筆
                        $("#show_sqlno_" + (i + 1)).val(item.show_sqlno);//流水號
                        $("#show_date_" + (i + 1)).val(dateReviver(item.show_date, "yyyy/M/d"));//展覽會優先權日
                        $("#show_name_" + (i + 1)).val(item.show_name);//展覽會名稱
                        if(xtype=="dmt"){//來源為案件主檔不能修改
                            $("#show_sqlno_" + (i + 1)).lock();
                            $("#show_date_" + (i + 1)).lock();
                            $("#show_name_" + (i + 1)).lock();
                        }
                    });
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取展覽優先權！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取展覽優先權！', modal: true, maxHeight: 500, width: 800 });
                //toastr.error("<a href='" + this.url + "' target='_new'>轉帳金額合計抓收費標準失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            }
        });

    }

    //展覽優先權增加一筆
    dmt_form.add_show = function () {
        var nRow = parseInt($("#shownum").val(), 10) + 1;
        //複製樣板
        var copyStr = $("#show_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabshow tbody").append(copyStr);
        $("#shownum").val(nRow);
        $(".dateField", $('#tr_show_' + nRow)).datepick();
    }

    //展覽優先權減少一筆
    dmt_form.del_show = function () {
        var nRow = CInt($("#shownum").val());
        $('#tr_show_' + nRow).remove();
        $("#shownum").val(Math.max(0, nRow - 1));
    }

    //檢查展覽優先權日期
    dmt_form.chk_showdate = function (pno) {
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

    //*****結案/復案註記
    //顯示隱藏結案原因
    dmt_form.showendremark = function (pformnm) {
        if($("#"+pformnm+"_end_type").val()=="016"){
            $("#"+pformnm+"_end_remark").val("").show();
        }else{
            if($("#"+pformnm+"_end_type").val()!=""){
                $("#"+pformnm+"_end_remark").val($("#"+pformnm+"_end_type :selected").text());
            }
            $("#"+pformnm+"_end_remark").hide();
        }
        dmt_form.get_enddata(pformnm);
    }

    //將各畫面值傳至資料庫值-結案資料
    dmt_form.get_enddata = function (pformnm) {
        if($("#"+pformnm+"_end_flag").prop("checked")==true){
            $("#tfy_end_flag").val("Y");
        }else{
            $("#tfy_end_flag").val("N");
        }
        $("#tfy_end_type").val($("#"+pformnm+"_end_type").val());
        $("#tfy_end_remark").val($("#"+pformnm+"_end_remark").val());
    }

    //將各畫面值傳至資料庫值-復案資料
    dmt_form.get_backdata = function (pformnm) {
        if($("#"+pformnm+"_back_flag").prop("checked")==true){
            $("#tfy_back_flag").val("Y");
        }else{
            $("#tfy_back_flag").val("N");
        }
        $("#tfy_back_remark").val($("#"+pformnm+"_back_remark").val());
    }

    //*****商標圖檔
    //商標圖檔上傳
    dmt_form.UploadAttach_photo = function () {
        var tfolder = "temp";
        var nfilename = "";
        if (main.formFunction == "Edit") {
            nfilename = reg.in_no.value
        }
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=dmt_photo" +
            "&nfilename=" + nfilename +
            "&draw_file=" + ($("#Draw_file1").val() || "") +
            "&folder_name=temp" +
            "&form_name=draw_attach_file" +
            "&file_name=Draw_file1" +
            "&prgid=<%=prgid%>" +
            "&btnname=butUpload1" +
            "&filename_flag=source_name";
        window.open(url, "", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //商標圖檔刪除
    dmt_form.DelAttach_photo = function () {
        if ($("#Draw_file1").val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if ($("#draw_attach_file").val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if (confirm("確定刪除上傳圖檔？")) {
            var url = getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&draw_file=" + $("#draw_attach_file").val() +
                "&btnname=butUpload1";
            window.open(url, "myWindowOne1", "width=700 height=600 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //window.open(url, "myWindowOne1", "width=1 height=1 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            $("#draw_attach_file").val("");
            $("#Draw_file1").val("");
        }
    }

    //商標圖檔檢視
    dmt_form.PreviewAttach_photo = function () {
        if ($("#Draw_file1").val() == "") {
            alert("請先上傳圖檔 !!");
            return false;
        }

        if ($("#draw_attach_file").val() == "") {
            alert("請先上傳圖檔 !!");
            return false;
        }

        var url = getRootPath() + "/sub/display_draw.aspx?draw_file=" + $("#draw_attach_file").val();
        //window.open(url, "window", "width=700,height=600,toolbar=yes,menubar=yes,resizable=yes,scrollbars=yes,status=0,top=50,left=80");
        window.open(url);
    }

</script>
