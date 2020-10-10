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
<input type="hidden" name="tfy_end_flag" id="tfy_end_flag">
<input type="hidden" name="tfy_end_type" id="tfy_end_type">
<input type="hidden" name="tfy_end_remark" id="tfy_end_remark">
<input type="hidden" name="tfy_back_flag" id="tfy_back_flag">
<input type="hidden" name="tfy_back_remark" id="tfy_back_remark">
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
		<td class=whitetablebg colspan=3 style="display:" id=DelayCase>
			<INPUT TYPE=text NAME=old_seq id=old_seq SIZE=5 MAXLENGTH=5 onblur="mainseqChange('old_seq')">-<INPUT TYPE=text NAME=old_seq1 id=old_seq1 SIZE=1 MAXLENGTH=1 value="_" onblur="mainseqChange('old_seq')">	
			<INPUT TYPE=button name=btnseq_ok id=btnseq_ok onclick="delayNO reg.old_seq.value,reg.old_seq1.value " value="確定">　<input type=button class="cbutton" name="Query" id="Query" value ="查詢主案件編號" style="width:140" onclick="Queryclick(reg.F_cust_seq.value)">
			<input type=button class="cbutton" name="Qry_step" id="Qry_step" value ="查詢案件進度" style="width:100" onclick="vbscript:Qstepclick reg.old_seq.value,reg.old_seq1.value">
			<input type=button class="c1button <%#Hide["brt51"]%>" name="Upd_seq" id="Upd_seq" value ="案件主檔維護" style="width:100" onclick="vbscript:Updseqclick reg.old_seq.value,reg.old_seq1.value">
			<input type="hidden" name=keyseq id=keyseq value="N">
		</td>
		<td class=whitetablebg colspan=3 style="display:" id=CaseNew>
			<INPUT TYPE=text NAME=New_seq id=New_seq SIZE=5 MAXLENGTH=5 class="sedit" readonly>-
			<select name=New_seq1 id=New_seq1 class="<%#Lock["brt51"]%>">
				<option value="_">一般</option>
				<option value="Z">Z_雜卷</option>
				<%if(Session["seBranch"].ToString()=="N")%><option value="M">M_大陸案</option>
			</select>
		</td>
		<td class=whitetablebg colspan=3 id=CaseNewAssign>
			<INPUT TYPE=text NAME=New_Ass_seq SIZE=5 MAXLENGTH=5>-<INPUT TYPE=text NAME=New_Ass_seq1 SIZE=1 MAXLENGTH=1 value="">	
		</td>
		<td class=lightbluetable align=right>母案本所編號：</td>
		<td class=whitetablebg colspan=3 >
			<INPUT TYPE=text NAME="tfzd_ref_no" id="tfzd_ref_no" SIZE=5 MAXLENGTH=5>-<INPUT TYPE=text NAME="tfzd_ref_no1" SIZE=1 MAXLENGTH=1 value="_">
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
            <input type="radio" name="tfzy_S_Mark" value="" onclick="change_mark(0)">商標
            <input type="radio" name="tfzy_S_Mark" value="S" onclick="change_mark(0)">92年修正前服務標章
            <input type="radio" name="tfzy_S_Mark" value="N" onclick="change_mark(0)">團體商標
            <input type="radio" name="tfzy_S_Mark" value="M" onclick="change_mark(0)">團體標章
            <input type="radio" name="tfzy_S_Mark" value="L" onclick="change_mark(0)">證明標章
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
		<td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_Tcn_ref id=tfzd_Tcn_ref SIZE=7 alt="『正商標號數』"  MAXLENGTH="7" onblur="fDataLen me.value,me.maxlength,me.alt"></TD>
		<td class=lightbluetable align=right>正商標類別：</td>
		<td class=whitetablebg colspan=3><input TYPE=text NAME=tfzd_Tcn_Class id=tfzd_Tcn_Class SIZE=20 alt="『正商標類別』"  MAXLENGTH="20" onblur="fDataLen me.value,me.maxlength,me.alt"></td>
	</tr>
	<tr style="display:none" id="tfzd_Smark1">
		<td class=lightbluetable align=right>正商標名稱：</td>
		<td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_Tcn_name id=tfzd_Tcn_name alt="『正商標名稱』" SIZE="20" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt"></TD>
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
	    <td class=whitetablebg colspan=3><INPUT TYPE=text NAME=tfzd_apply_no id=tfzd_apply_no SIZE=20 alt="『申請號數』" MAXLENGTH="20" onblur="vbscript:chk_dmt_applyno reg.tfzd_apply_no,9"><input type="hidden" name=O_apply_no></TD>
	    <td class=lightbluetable align=right>註冊號數：</td>
	    <td class=whitetablebg colspan=3><input TYPE=text NAME=tfzd_issue_no id=tfzd_issue_no SIZE=20 alt="『註冊號數』" MAXLENGTH="20" onblur="vbscript:chk_dmt_issueno reg.tfzd_issue_no,8" ><input type="hidden" name=O_issue_no></td>
    </tr>
    <tr>
	    <td class=lightbluetable align=right>商標名稱：</td>
	    <td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Appl_name id=tfzd_Appl_name alt="『商標名稱』" SIZE="60" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt"></TD>
    </tr>
	<tr id=fileupload>
		<td class=lightbluetable align=right>商標圖樣：</td>	
		<td class=whitetablebg colspan=7>	
			<input TYPE="hidden" id="file" name="file">
	        <input TYPE="text" name="Draw_file" id="tfz1_Draw_file" SIZE="50" maxlength="50" readonly>	    
		    <input type="button" class="cbutton" id="butUpload"   name="butUpload"  value="商標圖檔上傳" onclick="vbscript:UploadAttach_photo()" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="vbscript:DelAttach_photo()" >
            <input type="button" class="cbutton" id="btnDisplay"  name="btnDisplay" value="商標圖檔檢視" onclick="vbscript:PreviewAttach_photo()" >
	        <input type="hidden" name="draw_attach_file" id="draw_attach_file">
		</TD>
	</tr>	
	<tr>
		<td class=lightbluetable align=right>聲明不專用：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Oappl_name id=tfzd_Oappl_name alt="『不單獨主張專用』" SIZE="60" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt" ></TD>
	</tr>			
	<tr>
		<td class=lightbluetable align=right>圖樣中文部份：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Cappl_name id=tfzd_Cappl_name alt="『圖樣中文』" SIZE="60" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt" ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖樣外文部份：</td>
		<td class=whitetablebg colspan=7>
			外文：<INPUT TYPE=text NAME=tfzd_Eappl_name id=tfzd_Eappl_name alt="『圖樣外文』" SIZE="60" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt" ><br>
			中文字義：<input type=text name=tfzd_eappl_name1 id=tfzd_eappl_name1 alt="『中文字義』" SIZE="60" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt" ><br>
			讀音：<input type=text name=tfzd_eappl_name2 id=tfzd_eappl_name2 alt="『讀音』" SIZE="30" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt" >　
			語文別：<select NAME="tfzy_Zname_type" id="tfzy_Zname_type"><%#tfz_country%></select>
			<input type="hidden" name="tfzd_Zname_type" id="tfzd_Zname_type">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>圖形描述：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Draw id=tfzd_Draw alt="『圖形描述』" SIZE="50" MAXLENGTH="50" onblur="fDataLen me.value,me.maxlength,me.alt" ></TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right>記號說明：</td>
		<td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_Symbol id=tfzd_Symbol alt="『記號說明』" SIZE="50" MAXLENGTH="50" onblur="fDataLen me.value,me.maxlength,me.alt" ></TD>
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
            <input TYPE="text" NAME="tfzd_rej_no" id="tfzd_rej_no" SIZE="10" alt="『核駁號』"  MAXLENGTH="20" onblur="vbscript:chk_dmt_rejno reg.tfzd_rej_no,7">
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
				    <td class=whitetablebg colspan=7>共<input type="text" id=tfzr_class_count name=tfzr_class_count size=2 onchange="vbscript:add_button me.value">類
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
				    <td class="whitetablebg" colspan="7"><!--2013/1/22玉雀告知不顯示商標法施行細則第13條-->第<INPUT type="text" id=class1_## name=class1_## size=3 maxlength=3 onchange="vbscript:count_kind reg.class11.value,1">類</td>
			    </tr>
			    <tr class="tr_class_##" style="height:107.6pt">
				    <td class="lightbluetable" align="right" width="18%">商品名稱##：</td>			
				    <td class="whitetablebg" colspan="7">
                        <textarea id="good_name1_##" NAME="good_name1_##" ROWS="10" COLS="75" onchange="vbscript:good_name_count 'good_name11','good_count11'"></textarea>
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
					    <input type=button value ="增加一筆展覽會優先權" class="cbutton"   id=show_Add_button_dmt name=show_Add_button_dmt onclick="vbscript:call show_Add_button('dmt')">			
					    <input type=button value ="減少一筆展覽會優先權" class="cbutton"   id=show_Del_button_dmt name=show_Del_button_dmt onclick="vbscript:call delete_show('dmt','btn')">
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
		                    <input type=text size=10 maxlength=10 id='show_date_##' name='show_date_##' onblur="br_form.chk_showdate('##')" class="dateField" <%=Qclass%> />
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
