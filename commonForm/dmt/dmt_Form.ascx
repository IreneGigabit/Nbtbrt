<%@ Control Language="C#" ClassName="dmt_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfz_country = "", tfzy_end_code = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        if (prgid.ToLower() == "brt51") {//程序客收確認
            Lock["brt51"] = "Lock";
            Hide["brt51"] = "";
        } else {
            Lock["brt51"] = "";
            Hide["brt51"] = "Hide";
        }

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
            <Select id="tfy_case_stat" name="tfy_case_stat" onchange="dmt_form.new_oldcase()">
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
			    <INPUT TYPE=text NAME=old_seq id=old_seq SIZE=5 MAXLENGTH=5 onblur="dmt_form.mainseqChange('old_seq')">-<INPUT TYPE=text NAME=old_seq1 id=old_seq1 SIZE=1 MAXLENGTH=1 value="_" onblur="dmt_form.mainseqChange('old_seq')" style="text-transform:uppercase;">	
			    <INPUT TYPE=button name=btnseq_ok id=btnseq_ok onclick="delayNO(reg.old_seq.value,reg.old_seq1.value)" value="確定">
                <input type=button class="cbutton" name="Query" id="Query" value ="查詢主案件編號" onclick="dmt_form.Queryclick(reg.F_cust_seq.value)">
			    <input type=button class="cbutton" name="Qry_step" id="Qry_step" value ="查詢案件進度" onclick="dmt_form.Qstepclick(reg.old_seq.value,reg.old_seq1.value)">
			    <input type=button class="c1button <%#Hide.TryGet("brt51")%>" name="Upd_seq" id="Upd_seq" value ="案件主檔維護" onclick="dmt_form.Updseqclick(reg.old_seq.value,reg.old_seq1.value)">
			    <input type="text" name=keyseq id=keyseq value="N">
            </span>
            <span id=CaseNew><!--新案-->
			    <INPUT TYPE=text NAME=New_seq id=New_seq SIZE=5 MAXLENGTH=5 class="SEdit" readonly>-
			    <select name=New_seq1 id=New_seq1 class="<%#Lock.TryGet("brt51")%>">
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
			<INPUT TYPE=button Name="but_ref" id="but_ref" onclick="delayNO1(reg.tfzd_ref_no.value,reg.tfzd_ref_no1.value)"  class="bluebutton" value="母案複製">
			<!-- 程序客收移轉舊案要結案 2006/5/26 -->
			<input type=hidden name="endflag51" id="endflag51" value="X">
			<input type=hidden name="end_date51" id="end_date51">
			<input type=hidden name="end_code51" id="end_code51">
			<input type=hidden name="end_type51" id="end_type51">
			<input type=hidden name="end_remark51" id="end_remark51">
			<INPUT TYPE=button style="display:none" Name="but_end" id="but_end" onclick="dmt_form.btnendA8click('tfzd_ref_no',reg.tfzd_ref_no.value,reg.tfzd_ref_no1.value)"  class="redbutton" value="母案結案">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" rowspan=2>商標種類：</td>
		<td class="whitetablebg" colspan=7>
            <input type="radio" name="tfzy_S_Mark" value="" onclick="dmt_form.change_mark(0)">商標
            <span id="smark">
                <input type="radio" name="tfzy_S_Mark" value="S" onclick="dmt_form.change_mark(0)">92年修正前服務標章
            </span>
            <span id="smark1">
				<span id="fr_smark1">
                    <input type="radio" name="tfzy_S_Mark" value="N" onclick="dmt_form.change_mark(0)">團體商標
				</span>
				<span id="fr_smark2" style="display:">
                    <input type="radio" name="tfzy_S_Mark" value="M" onclick="dmt_form.change_mark(0)">團體標章
				</span>
				<span id="fr_smark3" style="display:">
                    <input type="radio" name="tfzy_S_Mark" value="L" onclick="dmt_form.change_mark(0)">證明標章
				</span>
			</span>
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
            <SELECT NAME=tfzy_Pul id=tfzy_Pul onchange=dmt_form.tfzd_showmark(this.value)>
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
	    <td class=whitetablebg colspan=7><INPUT TYPE=text NAME=tfzd_appl_name id=tfzd_appl_name alt="『商標名稱』" SIZE="60" MAXLENGTH="100" onblur="fDataLen(this)"></TD>
    </tr>
	<tr id=fileupload>
		<td class=lightbluetable align=right>商標圖樣：</td>	
		<td class=whitetablebg colspan=7>	
			<input TYPE="hidden" id="file" name="file">
	        <input TYPE="text" name="Draw_file" id="Draw_file" SIZE="50" maxlength="50" readonly>
			<input type="button" class="cbutton" id="butUpload" name="butUpload"  value="商標圖檔上傳" onclick="dmt_form.UploadAttach_photo('')" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="dmt_form.DelAttach_photo('')" >
            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="dmt_form.PreviewAttach_photo('')" >
	        <!--input type="hidden" name="draw_attach_file" id="draw_attach_file"-->
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
			<input type="hidden" name="tfzd_end_code" id="tfzd_end_code">
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">專用期限：</td>
		<td class="whitetablebg" colspan="3">
            <input TYPE="text" NAME="tfzd_dmt_term1" id="tfzd_dmt_term1" SIZE="10" class="dateField">～<input TYPE="text" NAME="tfzd_dmt_term2" id="tfzd_dmt_term2" SIZE="10" class="dateField">
		</TD>
		<td class="lightbluetable" align="right">延展次數：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="tfzd_renewal" id="tfzd_renewal" SIZE="2"></TD>
	</tr>
	<tr class='sfont9'>
		<td colspan=8>
			<TABLE id=tabdmt1 border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
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
					    <input type=text name=num1 id=num1 value="0"><!--畫面上有幾筆-->
				        <input type=text name=ctrlnum1 id=ctrlnum1 value="0">
					    <input type=text name=ctrlcount1 id=ctrlcount1 value="">
				    </td>
			    </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="class_template"><!--類別樣板-->
		        <tr class="tr_class_##">
				    <td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別，並以逗號分開(例如：1,5,32)。或輸入類別範圍，並以  -  (半形) 分開(例如：8-16)。也可複項組合(例如：3,5,13-32,35)">類別##：</td>		
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
				    <td class="whitetablebg" colspan="7">
                        <textarea id=grp_code1_## NAME=grp_code1_## ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)
                    </td>
			    </tr>
            </script>
			</table>
		</td>
	</tr>
	<tr class='sfont9'>
		<td colspan=8>
			<input type=hidden id=shownum_dmt name=shownum_dmt value="0">
			<TABLE id=tabshow_dmt border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
                <thead>
			    <TR class=whitetablebg align=center>
				    <TD colspan=3 >
				        <input type=button value ="增加一筆展覽會優先權" class="cbutton" id=show_Add_button_dmt name=show_Add_button_dmt onclick="dmt_form.add_show()">			
				        <input type=button value ="減少一筆展覽會優先權" class="cbutton" id=show_Del_button_dmt name=show_Del_button_dmt onclick="dmt_form.del_show()">
				    </TD>
			    </TR>
			    <tr>
				    <td class="lightbluetable" align="center" ></td>	
				    <td class="lightbluetable" align="center" >展覽會優先權日</td>
				    <td class="lightbluetable" align="center" >展覽會名稱</td>	
			    </tr>
                </thead>
                <tbody></tbody>
                <script type="text/html" id="dmt_show_template"><!--展覽會優先權樣板-->
	                <tr id=tr_show_dmt_##>
		                <td class=whitetablebg align=center>
                            <input type=text id='shownum_dmt_##' name='shownum_dmt_##' class=SEdit readonly size=2 value='##.'>
                            <input type=hidden id='show_sqlno_dmt_##' name='show_sqlno_dmt_##'>
		                </td>
		                <td class=whitetablebg align=center>
		                    <input type=text size=10 maxlength=10 id='show_date_dmt_##' name='show_date_dmt_##' onblur="dmt_form.chk_showdate('##')" class="dateField" />
		                </td>
		                <td class=whitetablebg align=center>
		                    <input type=text id='show_name_dmt_##' name='show_name_dmt_##' size=50 maxlength=100 />
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
        if(main.prgid=="brt51"&&main.ar_form=="A8"){
            $("#but_end").show();
        }
        dmt_form.Add_class(1);//預設顯示第1筆
    }

    //新案(指定編號)
    dmt_form.chkseq = function () {
        if ($("#tfy_case_stat").val()!="SN") return false;
        //chk案件主檔需有資料
        if ($("#New_Ass_seq").val()!="") {
            var url=getRootPath() + "/brt1m/chk_dmt.aspx?p1=Y&p2=A&seq=" +$("#New_Ass_seq").val()+ "&seq1=" +$("#New_Ass_seq1").val();
            scriptByGet("chk案件主檔",url);
        }
        $("#dseqa_1").val($("#New_Ass_seq").val());
        $("#dseq1a_1").val($("#New_Ass_seq1").val());
        $("#dseqb_1").val($("#New_Ass_seq").val());
        $("#dseq1b_1").val($("#New_Ass_seq1").val());
    }
    //新案-副號選擇
    var old_ar_mark = "";
    $("#New_seq1").change(function () {
        $("#tfzb_seq1").val($("#New_seq1").val());
        if ($("#New_seq1").val() == "M") {
            $("#tfy_Ar_mark").val("X");////請款註記:大陸進口案
            old_ar_mark = "X";
        } else {
            if (old_ar_mark == "X") {
                $("#tfy_Ar_mark").val("");
                old_ar_mark = "";
            }
        }

        $("#dseqa_1").val($("#New_seq").val());
        $("#dseq1a_1").val($("#New_seq1").val());
        $("#dseqb_1").val($("#New_seq").val());
        $("#dseq1b_1").val($("#New_seq1").val());
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

    //商標種類(x:0=案件主檔→交辦內容,x:1=交辦內容→案件主檔)
    dmt_form.change_mark = function (x,obj) {
        if (x == 1) {
            $("input[name='tfzy_S_Mark'][value='" + $(obj).val() + "']").prop("checked", true);
            if ($("#tfy_Arcase").val() == "FC4") {
                $("#tfzy_Pul").val("2");
                dmt_form.tfzd_showmark($("#tfzy_Pul").val());
            }
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
            $("#s_marka_1").val("92年修正前服務標章");
            $("#s_markb_1").val("92年修正前服務標章");
        }else if(smark_val=="N"){
            $("#s_marka_1").val("團體商標");
            $("#s_markb_1").val("團體商標");
        }else if(smark_val=="M"){
            $("#s_marka_1").val("團體標章");
            $("#s_markb_1").val("團體標章");
        }else if(smark_val=="L"){
            $("#s_marka_1").val("證明標章");
            $("#s_markb_1").val("證明標章");
        }else{
            $("#s_marka_1").val("商標");
            $("#s_markb_1").val("商標");
        }
    };

    //註冊號數帶資料到交辦內容
    $("#tfzd_issue_no").blur(function () {
        $("#O_issue_no").val($(this).val());
        $("#fr3_issue_no").val($(this).val());
        $("#new_no21").val($(this).val());
        $("#fr4_issue_no").val($(this).val());
        $("#issue_nob_1").val($(this).val());
        $("#fr1_issue_no").val($(this).val());
        $("#fr2_issue_no").val($(this).val());
        $("#fr_issue_no").val($(this).val());
    });

    //商標名稱帶資料到交辦內容
    $("#tfzd_appl_name").blur(function () {
        if (check_CustWatch("appl_name",$(this).val())==true){
            return false;
        }
        $("#ncname111").val($(this).val());
        $("#ncname121").val($(this).val());
        $("#appl_namea_1").val($(this).val());
        $("#appl_nameb_1").val($(this).val());
        $("#fr1_appl_name").val($(this).val());
        $("#fr2_appl_name").val($(this).val());
        $("#fr3_appl_name").val($(this).val());
        $("#fr4_appl_name").val($(this).val());
        $("#frf_Appl_name").val($(this).val());
        $("#fr_appl_name").val($(this).val());
    });

    //申請號數帶資料到交辦內容
    $("#tfzd_apply_no").blur(function () {
        $("#O_apply_no").val($(this).val());
        $("#fr_apply_no").val($(this).val());
        $("#new_no11").val($(this).val());
        $("#apply_noa_1").val($(this).val());
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
                $("#tabdmt1 tbody").append(copyStr);
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

        var nclass = $("#tabdmt1>tbody input[id^='class1_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        });
        $("#tfzr_class").val(nclass.get().join(','));
        $("#tfzr_class_count").val(Math.max(CInt($("#tfzr_class_count").val()), nclass.length));//回寫共N類

        if ($("#ar_form").val() == "A3") {//註冊費交辦內容連動
            $("#fr_class").val($("#tfzr_class").val());
        }
    }

    //*****展覽優先權抓資料
    dmt_form.getshow = function (xtype) {
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
                        $("#show_sqlno_dmt_" + (i + 1)).val(item.show_sqlno);//流水號
                        $("#show_date_dmt_" + (i + 1)).val(dateReviver(item.show_date, "yyyy/M/d"));//展覽會優先權日
                        $("#show_name_dmt_" + (i + 1)).val(item.show_name);//展覽會名稱
                        if(xtype=="dmt"){//來源為案件主檔不能修改
                            $("#show_sqlno_dmt_" + (i + 1)).lock();
                            $("#show_date_dmt_" + (i + 1)).lock();
                            $("#show_name_dmt_" + (i + 1)).lock();
                        }
                    });
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>抓取展覽優先權！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '抓取展覽優先權！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    }

    //展覽優先權增加一筆
    dmt_form.add_show = function () {
        var nRow = CInt($("#shownum_dmt").val()) + 1;
        //複製樣板
        var copyStr = $("#dmt_show_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabshow_dmt tbody").append(copyStr);
        $("#shownum_dmt").val(nRow);
        $(".dateField", $('#tr_show_dmt_' + nRow)).datepick();
    }

    //展覽優先權減少一筆
    dmt_form.del_show = function () {
        var nRow = CInt($("#shownum_dmt").val());
        $('#tr_show_dmt_' + nRow).remove();
        $("#shownum_dmt").val(Math.max(0, nRow - 1));
    }

    //檢查展覽優先權日期
    dmt_form.chk_showdate = function (pno) {
        ChkDate($("#show_date_dmt_" + pno)[0]);

        if ($("#show_date_dmt_" + pno).val() != "") {
            var sdate = new Date($("#show_date_dmt_" + pno).val()).setHours(0, 0, 0, 0);
            var today = new Date().setHours(0, 0, 0, 0);
            if (sdate > today) {
                alert("展覽優先權日期不可大於系統日期!!");
                $("#show_date_dmt_" + pno).focus();
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
    dmt_form.UploadAttach_photo = function (pfld) {
        var tfolder = "temp";
        var nfilename = "";
        if (main.formFunction == "Edit") {
            nfilename = reg.in_no.value
        }
        var pfile_name = "Draw_file";
        if (pfld!=""){
            //for爭救案,tfp2:DO1form
            pfile_name=pfld+"_draw_file";
        }
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=dmt_photo" +
            "&nfilename=" + nfilename +
            "&draw_file=" + ($("#" + pfile_name).val() || "") +
            "&folder_name=temp" +
            "&form_name=draw_attach_file" +
            "&file_name=" + pfile_name +
            "&prgid=<%=prgid%>" +
            "&btnname=butUpload"+pfld +
            "&filename_flag=source_name";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //商標圖檔刪除
    dmt_form.DelAttach_photo = function (pfld) {
        var pfile_name = "Draw_file";
        if (pfld != "") {
            //for爭救案,tfp2:DO1form
            pfile_name = pfld + "_draw_file";
        }

        if ($("#" + pfile_name).val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if ($("#draw_attach_file").val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if (confirm("確定刪除上傳圖檔？")) {
            var url = getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&draw_file=" + $("#draw_attach_file").val() +
                "&btnname=butUpload" + pfld;
            window.open(url, "myWindowOne1", "width=700 height=600 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //window.open(url, "myWindowOne1", "width=1 height=1 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            $("#draw_attach_file").val("");
            $("#" + pfile_name).val("");
        }
    }

    //商標圖檔檢視
    dmt_form.PreviewAttach_photo = function (pfld) {
        var pfile_name = "Draw_file";
        if (pfld != "") {
            //for爭救案,tfp2:DO1form
            pfile_name = pfld + "_draw_file";
        }

        if ($("#" + pfile_name).val() == "") {
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


    //查詢主案件編號
    dmt_form.Queryclick = function(cust_seq) {
        //***todo
        window.open("brta21Query.aspx?cust_seq="+cust_seq ,"myWindowOne", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
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

    //*********正聯防	
    dmt_form.tfzd_showmark = function (xmark) {
        if (IsNumeric(xmark)) {
            $("#tfzd_Smark,#tfzd_Smark1").show();//正商標號數/正商標類別/正商標名稱/正商標種類
            if (main.ar_form != "A5") {
                if ($("#tfy_case_stat").val() == "OO") {//案件狀態
                    $("#tfzd_Tcn_mark").lock();//正商標種類
                } else {
                    $("#tfzd_Tcn_mark").unlock();
                }
            }
        } else {
            $("#tfzd_Smark,#tfzd_Smark1").hide();
            $("#tfzd_Tcn_mark").val("");//***正商標種類
            $("#tfzd_Tcn_ref").val("");//***正商標號數
            $("#tfzd_Tcn_name").val("");//***正商標名稱
            $("#tfzd_Tcn_Class").val("");//***正商標類別
        }
    }

    //*****將特定欄位disabled
    function Filereadonly(){
        $("input[id^='tfzd'],input[name^='tfzd']").lock();
        $("input[id^='fr'],input[name^='fr']").lock();
        if (main.seq == "") {
            $("input[id^='tfzd'],input[name^='tfzd']").val("");
            $("input[id^='fr'],input[name^='fr']").val("");
        }
        $("input[name=tfzy_S_Mark],input[name=fr_S_Mark]").lock();//商標種類
        $("input[name=tfzd_s_mark2]").unlock();//商標種類2
        $("#no").lock();//號數
        $("#tfzy_Pul").lock();//正聯防
        $("#Draw_file").val("");//商標圖樣
        $("#butUpload,#btnDelAtt").lock();
        $("#but_ref").hide();//母案複製
        $("input[name=tfzy_color]").lock();//圖樣顏色
        $("#tfzy_Zname_type").lock();//語文別
        $("#pfzd_prior_date").lock();//優先權申請日
        $("#tfzy_prior_country").lock();//優先權首次申請國家
        $("#tfzy_end_code").lock();//結案代碼
        $("#tfzr_class_count").val("").lock();//類別
        $("#tfzr_class").val("").lock();
        $("#class1_1").val("").lock();
        $("#good_name1_1").val("").lock();
        $("#good_count1_1").val("").lock();
        $("#grp_code1_1").val("").lock();
        //主檔展覽優先權欄位
        $("#show_Add_button_dmt,#show_Del_button_dmt").lock();
        $("#tabshow_dmt input[type='text']").lock();
        //分割
        $("#tft1_mod_count11,#tft2_mod_count2").lock();//件數
        $("#new_no11").lock();//申請案號
        $("#new_no21").lock();//註冊案號
        $("#ncname111,#ncname121").lock();//商標/標章名稱
    }

    //*****將特定欄位enabled
    function Filecanput(){
        $("input[id^='tfzd'],input[name^='tfzd']").unlock().val("");
        $("input[id^='fr'],input[name^='fr']").unlock().val("");
        $("input[name=tfzy_S_Mark],input[name=fr_S_Mark]").unlock();//商標種類
        $("input[name=tfzd_s_mark2]").unlock();//商標種類2
        $("#no").unlock();//號數
        $("#tfzy_Pul").unlock();//正聯防
        $("#Draw_file").val("");//商標圖樣
        $("#butUpload,#btnDelAtt").unlock();
        $("#but_ref").show();//母案複製
        $("input[name=tfzy_color]").unlock();//圖樣顏色
        $("#tfzy_Zname_type").unlock();//語文別
        $("#pfzd_prior_date").unlock();//優先權申請日
        $("#tfzy_prior_country").unlock();//優先權首次申請國家
        $("#tfzy_end_code").unlock();//結案代碼
        $("#tfzr_class_count").val("").unlock();//類別
        $("#tfzr_class").val("").unlock();
        $("#class1_1").val("").unlock();
        $("#good_name1_1").val("").unlock();
        $("#good_count1_1").val("").unlock();
        $("#grp_code1_1").val("").unlock();
        //主檔展覽優先權欄位
        $("#show_Add_button_dmt,#show_Del_button_dmt").unlock();
        $("#tabshow_dmt input[type='text']").unlock();
        //分割
        //$("#tft1_mod_count11,#tft2_mod_count2").unlock();//件數
        $("#new_no11").unlock();//申請案號
        $("#new_no21").unlock();//註冊案號
        //$("#ncname111,#ncname121").unlock();//商標/標章名稱
    }

    //******新舊案切換控制
    dmt_form.new_oldcase = function () {
        //function new_oldcase() {
        if ($("#tfy_case_stat").val() == "NN") {//新案
            $("#DelayCase,#CaseNewAssign").hide();//舊案/新案(指定編號)
            $("#CaseNew").show();//新案
            $("#A9Ztr_endtype,#A9Ztr_backflag").hide();//結案/復案
            if(main.prgid=="brt52"){
                $("#New_seq,#tfzb_seq").val(jMain.case_main[0].seq);
                $("#New_seq1,#tfzb_seq1").val(jMain.case_main[0].seq1);
            }else{
                $("#New_seq").val("");
            }
            Filecanput();//***todo將特定欄位enabled
            $("#F_cust_seq").unlock();
            $("#btncust_seq").show();
            dmt_form.Add_class(1);//類別預設顯示第1筆
            $("#keyseq").val("N");
            $("#btnseq_ok").unlock();//舊案[查詢主案件編號]
            $("#tfzd_ref_no1").val("_");//母案本所編號副號
            //將展覽優先權資料清空
            for (var i = 1; i <= CInt($("#shownum_dmt").val()) ; i++) {
                dmt_form.del_show();
            }
            //一案多件
            $("#dseqa_1,#dseqb_1").lock().val("");
            $("#dseq1a_1,#dseq1b_1").lock().val("_");
            $("#btndseq_oka_1,#btncasea_1,#btndseq_okb_1,#btncaseb_1").hide();//[確定][案件主檔查詢]
            $("#s_marka_1,#s_markb_1").val("");//商標種類
            $("#appl_namea_1,#appl_nameb_1,#apply_noa_1,#issue_nob_1").val("");//商標/標章名稱/申請號數/註冊號數
            $("#case_stat1a_1NN,#case_stat1b_1NN").prop("checked", true);//新舊案
            $("#btnQuerya_1,#btnQueryb_1").hide();//[查詢主案件編號]
        } else if ($("#tfy_case_stat").val() == "SN") {//新案(指定編號)
            $("#DelayCase,#CaseNew").hide();//舊案/新案
            $("#CaseNewAssign").show();//新案(指定編號)
            $("#A9Ztr_endtype,#A9Ztr_backflag").hide();//結案/復案
            Filecanput();//***todo將特定欄位enabled
            $("#F_cust_seq").unlock();
            $("#btncust_seq").show();
            dmt_form.Add_class(1);//預設顯示第1筆
            $("#keyseq").val("N");
            $("#btnseq_ok").unlock();//舊案[查詢主案件編號]
            $("#tfzd_ref_no1").val("_");//母案本所編號副號
            //將展覽優先權資料清空
            for (var i = 1; i <= CInt($("#shownum_dmt").val()) ; i++) {
                dmt_form.del_show();
            }
            //一案多件
            $("#dseqa_1,#dseqb_1").lock().val("");
            $("#dseq1a_1,#dseq1b_1").lock().val("_");
            $("#btndseq_oka_1,#btncasea_1,#btndseq_okb_1,#btncaseb_1").hide();//[確定][案件主檔查詢]
            $("#s_marka_1,#s_markb_1").val("");//商標種類
            $("#appl_namea_1,#appl_nameb_1,#apply_noa_1,#issue_nob_1").val("");//商標/標章名稱/申請號數/註冊號數
        } else if ($("#tfy_case_stat").val() == "OO") {//舊案
            $("#DelayCase").show();//舊案
            $("#CaseNew,#CaseNewAssign").hide();//新案/新案(指定編號)
            $("#A9Ztr_endtype,#A9Ztr_backflag").show();//結案/復案
            dmt_form.Add_class(1);//預設顯示第1筆
            //一案多件
            $("#dseqa_1,#dseqb_1").unlock();
            $("#dseq1a_1,#dseq1b_1").unlock();
            $("#btndseq_oka_1,#btncasea_1,#btndseq_okb_1,#btncaseb_1").show();//[確定][案件主檔查詢]
            $("#s_marka_1,#s_markb_1").val("");//商標種類
            $("#appl_namea_1,#appl_nameb_1,#apply_noa_1,#issue_nob_1").val("");//商標/標章名稱/申請號數/註冊號數
            $("#case_stat1a_1OO,#case_stat1b_1OO").prop("checked", true);//新舊案
            Filereadonly();//***todo將特定欄位disabled
            //***接收舊案檢索資料
            if (main.formFunction == "Edit") {
                $("#old_seq,#tfzb_seq").val(jMain.case_main[0].seq);
                $("#old_seq1,#tfzb_seq1").val(jMain.case_main[0].seq1);
            } else {
                $("#tfzb_seq").val(main.seq);
                $("#tfzb_seq1").val("_");
                if(main.seq1!=""){
                    $("#tfzb_seq1").val(main.seq1);
                }
            }
            //舊案時不可更改區所編號
            $("#F_cust_seq").lock();
            $("#btncust_seq").hide();
            if (main.seq == "") {
                $("#tfzy_Pul,#tfzd_Pul").val("");
                $("#tfzd_S_Mark").val("");
                $("input[name=tfzy_S_Mark]").prop("checked", false);
                $("input[name=tfzy_color]").prop("checked", false);
            }
        }
    }
</script>
