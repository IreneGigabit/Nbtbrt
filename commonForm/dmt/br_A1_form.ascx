<%@ Control Language="C#" ClassName="br_A1_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/dmt/br_A1_remark1.ascx" TagPrefix="uc1" TagName="br_A1_remark1" %>


<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfz1_agt_no="",tfz_country = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        if (prgid.ToLower() == "brt51") {//程序客收確認
            Lock["brt51"] = "Lock";
        } else {
            Lock["brt51"] = "";
        }

        //代理人
        tfz1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        //語文別/國家
        tfz_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
    }
</script>

<%=Sys.GetAscxPath(this)%>
<INPUT TYPE=hidden NAME=tfz1_S_Mark value="">
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr id="showseq1">
		<td class=lightbluetable align=right width="10%" >案件編號：</td>
		<td class=whitetablebg colspan=7>
			<INPUT TYPE=text NAME=tfz1_seq SIZE=5 MAXLENGTH=5 readonly class="SEdit">-
			<select name=tfz1_seq1 onchange="seq1_conctrl()" class="<%=Lock["brt51"]%>">
			<option value="_">一般</option>
			<option value="M">M_大陸案</option>
			</select>
		</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right" width="10%" rowspan=2>商標種類：</td>
		<td class="whitetablebg" colspan=7><input type="radio" name="span_mark1" disabled>商標<input type="radio" name="span_mark1" disabled>團體商標<input type="radio" name="span_mark1" disabled>團體標章<input type="radio" name="span_mark1" disabled>證明標章
		</TD>
	</tr>	
	<tr >
		<td class="whitetablebg" colspan=7>
			<input type="radio" name="tfz1_s_mark2" value="A">平面
			<input type="radio" name="tfz1_s_mark2" value="B">立體
			<input type="radio" name="tfz1_s_mark2" value="C">聲音
			<input type="radio" name="tfz1_s_mark2" value="D">顏色
			<input type="radio" name="tfz1_s_mark2" value="E">全像圖
			<input type="radio" name="tfz1_s_mark2" value="F">動態
			<!--input type="radio" name="tfz1_s_mark2" value="G">其他-->
			<input type="radio" name="tfz1_s_mark2" value="H">位置
			<input type="radio" name="tfz1_s_mark2" value="I">氣味
			<input type="radio" name="tfz1_s_mark2" value="J">觸覺
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">客戶卷號：</td>
		<td class="whitetablebg" colspan=5>
			<input type="text" id="tfz1_cust_prod" name="tfz1_cust_prod" size="15">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top"><strong>※代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
            <select NAME="tfz1_agt_no" SIZE="1"><%#tfz1_agt_no%></SELECT>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="5%"><strong>壹、<span id=span_FA1></span></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" STYLE="cursor:pointer;COLOR:BLUE" ID="nAppend" name="nAppend" onclick="PMARK(p1Appl_name)">一、<u><span id=span_FA11></span></td>
		<td class="whitetablebg" colspan=7><input TYPE="text"  NAME="tfz1_Appl_name" alt="『商標(標章)名稱』" SIZE="60" MAXLENGTH="100" onblur="vbscript:appl_name_onblur me.value,me.maxlength,me.alt">
			<input TYPE="hidden" id="file1" name="file1" value=>
	        <input TYPE="text" id="tfz1_Draw_file" name="Draw_file1" SIZE="50" maxlength="50" readonly>	    
			<input type="button" class="cbutton" id="butUpload1"   name="butUpload1"  value="商標圖檔上傳" onclick="vbscript:UploadAttach_photo('1')" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="vbscript:DelAttach_photo('1')" >
            <input type="button" class="cbutton" id="btnDisplay"  name="btnDisplay" value="商標圖檔檢視" onclick="vbscript:PreviewAttach_photo('1')" >
	    </td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p1Color)"><u>二、圖樣顏色：</td>
		<td class="whitetablebg" colspan="7">
		<input TYPE="radio" NAME="tfz1_color" ID="tfz1_colorB" value="B">墨色
		<input TYPE="radio" NAME="tfz1_color" ID="tfz1_colorC" value="C">彩色
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(p1Oappl_name)"><u>三、聲明不專用：</td>
		<td class="whitetablebg" colspan=7><input TYPE="text" NAME="tfz1_Oappl_name" SIZE="60" alt="『不主張專用』" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt"></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a1Eappl_name)">四、<u><span id=span_FA12></span></td>
	</tr>			
	<tr>
		<td class="lightbluetable" align="right" >中文：</td>
		<td class="whitetablebg" colspan="7"><input TYPE="text" NAME="tfz1_Cappl_name" SIZE="50" alt="『商標圖樣分析中文』" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >外文：</td>
		<td class="whitetablebg" colspan="7">
		<input TYPE="text" NAME="tfz1_Eappl_name" SIZE="30" alt="『商標圖樣分析外文』" MAXLENGTH="100" onblur="fDataLen me.value,me.maxlength,me.alt">　語文別：
        <select NAME="tfz1_Zname_type" SIZE="1"><%#tfz_country%></select><br>
		中文字義：<input TYPE="text" NAME="tfz1_Eappl_name1" SIZE="30" MAXLENGTH="100" alt="『圖樣分析英文~中文字義』"  onblur="fDataLen me.value,me.maxlength,me.alt">
		<span style="display:none">　讀音：<input TYPE="text" NAME="tfz1_Eappl_name2" SIZE="30" MAXLENGTH="100" alt="『圖樣分析英文~讀音』"  onblur="fDataLen me.value,me.maxlength,me.alt"></span>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >圖形：</td>
		<td class="whitetablebg" colspan="7"><input TYPE="text" NAME="tfz1_Draw" SIZE="30" MAXLENGTH="50"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >記號：</td>
		<td class="whitetablebg" colspan="7"><input TYPE="text" NAME="tfz1_Symbol" SIZE="30" MAXLENGTH="50"></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(ztextp)"><strong>貳、<u>優先權聲明</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">申請日：</td>
		<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="pfz1_prior_date" SIZE="10" class="dateField">
		</TD>
		<td class="lightbluetable" align="right">首次申請國家：</td>
		<td class="whitetablebg">
            <select NAME="tfz1_prior_country" SIZE="1"><%#tfz_country%></select>
		    申請案號：<input type="text" name=tfz1_prior_no size=20 maxlength="20">
	    </td>
	</tr>
	<!--FA1的展覽會優先權畫面-->
	<tr>
		<td colspan=8 class="whitetablebg">
			<input type=hidden name=shownum_FA1 value="0">
			<TABLE id=tabshow_FA1 name=tabshow_FA1 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
			<tr>
				<td class="lightbluetable" colspan="3" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ><strong>參、<u>展覽會優先權聲明</td>
			</tr>
			<TR class=whitetablebg align=center>
				<TD colspan=3 >
					<input type=button value ="增加一筆展覽會優先權" class="cbutton"   id=show_Add_button_FA1 name=show_Add_button_FA1 onclick="show_Add_button('FA1')">			
					<input type=button value ="減少一筆展覽會優先權" class="cbutton"   id=show_Del_button_FA1 name=show_Del_button_FA1 onclick="delete_show('FA1','btn')">
				</TD>
			</TR>
			<tr>
				<td class="lightbluetable" align="center" ></td>	
				<td class="lightbluetable" align="center" >展覽會優先權日</td>
				<td class="lightbluetable" align="center" >展覽會名稱</td>	
			</tr>
			</table>
		</td>	
	</tr>
	<tr>
		<td colspan=8 class="whitetablebg"><!--伍、陸-->
	    </td>
    </tr>
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top"><strong>柒、簽章及具結：</strong></td>
    </tr>	
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top" >備註：本案另涉有他案時，請於備註欄內填明。</td>
    </tr>			
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top"><INPUT type="radio" name="ttz1_RCode" value="R1" onclick="CopyStr1(reg.tfz1_remark2,'1',me.value)">本案需俟註冊第<input TYPE="text" NAME="ttz1_R1" SIZE="10" MAXLENGTH="50" onchange="call CopyStr1(reg.tfz1_remark2,'0',me.value)">號商標爭議案確定後，再行審理。</td>
    </tr>	
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top"><INPUT type="radio" name="ttz1_RCode" value="R9" onclick="CopyStr1(reg.tfz1_remark2,'1',me.value)">其他<input TYPE="text" NAME="ttz1_R9" SIZE="50" onchange="call CopyStr1(reg.tfz1_remark2,'0',me.value)">
	    <input TYPE="hidden" NAME="tfz1_remark2" value="">
	    </td>
    </tr>
    <tr>
        <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a5Attech)"><strong><u>附件：</u></strong>
            <input type="text" id="tfz_remark1" name="tfz_remark1">
        </td>
    </tr>
    <tr class='sfont9'>
        <td colspan=8 id="br_remark1"></td>
    </tr>
</TABLE>

<!--FA1,FA5的類別畫面-->
<script type="text/html" id="br1_1">
	<TABLE id=tabbr1 name=tabbr1 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p1Good)"><strong>陸、<u>指定使用商品類別及名稱</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" >類別種類：</td>
			<td class="whitetablebg" colspan="7" >
				<input type="radio" id=tfz1_class_type name=tfz1_class_type value="int">國際分類
				<input type="radio" id=tfz1_class_type name=tfz1_class_type value="old" disabled>舊類
			</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" title="請輸入類別，並以逗號分開(例如：1,5,32)。">類別項目：</td>
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tfz1_class_count name=tfz1_class_count size=2 onchange="call add_button_FA1(me.value)">類
				<input type=hidden name=ctrlnum1 value="1">
				<input type=hidden name=ctrlcount1 value="">
				<input type=hidden name=num1 value="1">
				<input type="text" name=tfz1_class  id=tfz1_class readonly>
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" style="cursor:pointer" >類別1：</td>		
			<td class="whitetablebg" colspan="7">第<INPUT type="text" id=class1 name=class11 size=3 maxlength=3 onchange="call count_kind(reg.class11.value,1)">類</td>		
		</tr>
		<tr style="height:107.6pt">
			<td class="lightbluetable" align="right" width="18%">商品名稱1：</td>			
			<td class="whitetablebg" colspan="7"><textarea NAME="good_name11" ROWS="10" COLS="75" onchange="call good_name_count('good_name11','good_count11')"></textarea><br>共<input type="text" name=good_count11 size=2>項</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">商品群組代碼1：</td>
			<td class="whitetablebg" colspan="7"><textarea NAME=grp_code11 ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		</tr>
	</table>
</script>
<script type="text/html" id="br1_9">
	<!--FA9類別畫面-->
	<TABLE id=tabbr9 name=tabbr9 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p3Good)"><strong>伍、<u>團體標章表彰之內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE"">表彰：</td>
			<td class="whitetablebg" colspan="7">
			<input type="text" name="tf91_good_name" ID="tf91_good_name" size=60 value="">會員之會籍。（填寫申請人名稱）
			<input type="hidden" name="tfz1_good_name" ID="tfz1_good_name">
			</td>
		</tr>	
	</table>
</script>
<script type="text/html" id="br1_D">
	<!--FAD類別畫面-->
	<TABLE id=tabbrD name=tabbrD style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p4Good)"><strong>陸、<u>標章證明標的及內容</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">一、證明標的：</td>
		<td class="whitetablebg" colspan="7">
		<input TYPE="radio" NAME="pul_D" ID="pul_D" value="3">商品
		<input TYPE="radio" NAME="pul_D" ID="pul_D" value="4">服務
		<input TYPE="hidden" NAME="tfz1_pul" ID="tfz1_pul">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">二、證明內容：</td>
		<td class="whitetablebg" colspan="7">
		<input type="test" name="tfd1_good_name" ID="tfd1_good_name" size=50>
		</td>
	</tr>	
	</table>
</script>

<script type="text/html" id="br1_2">
	<!--FA2,FA6類別畫面-->
		<TABLE id=tabbr2 name=tabbr2 style="display:" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class=lightbluetable colspan=8 valign=top STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p2Good)"><strong>陸、<U>指定使用商品／服務類別及名稱</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" >類別種類：</td>
			<td class="whitetablebg" colspan="7" >
				<input type="radio" id=tfz2_class_type name=tfz2_class_type value="int">國際分類
				<input type="radio" id=tfz2_class_type name=tfz2_class_type value="old" disabled>舊類
			</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" title="請輸入類別，並以逗號分開(例如：1,5,32)。">類別項目：</td>
			<input type=hidden name=ctrlnum2 value="1">
				<input type=hidden name=ctrlcount2 value="">
				<input type=hidden name=num2 value="1">
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tfz2_class_count name=tfz2_class_count size=2 onchange="call add_button_FA2(me.value)">類
				<input type="text" name=tfz2_class  id=tfz2_class readonly>
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" style="cursor:hand" >類別1：</td>		
			<td class="whitetablebg" colspan="7">第<INPUT type="text" id=class21 name=class21 size=3 maxlength=3 onchange="call count_kind2(reg.class21.value,1)">類</td>		
		</tr>
		<tr style="height:107.6pt">
			<td class="lightbluetable" align="right" width="18%">商品名稱1：</td>			
			<td class="whitetablebg" colspan="7"><textarea NAME="good_name21" ROWS="10" COLS="75" onchange="call good_name_count('good_name21','good_count21')"></textarea><br>共<input type="text" name=good_count21 size=2>項</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">商品群組代碼1：</td>
			<td class="whitetablebg" colspan="7"><textarea NAME=grp_code21 ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		</tr>
		</table>
</script>
<script type="text/html" id="br1_A">
	<!--FAA類別畫面-->
		<TABLE id=tabbrA name=tabbrA style="display:none" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p3Good)"><strong>伍、<u>團體標章表彰之內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" STYLE="cursor:hand;COLOR:BLUE"">表彰：</td>
			<td class="whitetablebg" colspan="7">
			<input type="text" name="tfA2_good_name" ID="tfA2_good_name" size=60 value="">會員之會籍。（填寫申請人名稱）
			<input type="hidden" name="tfz2_good_name" ID="tfz2_good_name">
			</td>
		</tr>	
		</table>
</script>
<script type="text/html" id="br1_E">
	<!--FAE類別畫面-->
		<TABLE id=tabbrE name=tabbrE style="display:none" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p4Good)"><strong>陸、<u>標章證明標的及內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">一、證明標的：</td>
			<td class="whitetablebg" colspan="7">
			<input TYPE="radio" NAME="pul_E" ID="pul_E" value="3">商品
			<input TYPE="radio" NAME="pul_E" ID="pul_E" value="4">服務
			<input TYPE="hidden" NAME="tfz2_pul" ID="tfz2_pul">
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">二、證明內容：</td>
			<td class="whitetablebg" colspan="7">
			<input type="test" name="tfe2_good_name" ID="tfe2_good_name" size=50>
			</td>
		</tr>	
		</table>
</script>

<script type="text/html" id="br1_3">
	<!--FA3,FA7類別畫面-->
		<TABLE id=tabbr3 name=tabbr3 style="display:" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class=lightbluetable colspan=8 valign=top STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(a3Good)"><strong>陸、<U>指定使用商品／服務類別及名稱</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" >類別種類：</td>
			<td class="whitetablebg" colspan="7" >
				<input type="radio" id=tfz3_class_type name=tfz3_class_type value="int">國際分類
				<input type="radio" id=tfz3_class_type name=tfz3_class_type value="old" disabled>舊類
			</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" title="請輸入類別，並以逗號分開(例如：1,5,32)。">類別項目：</td>
			<input type=hidden name=ctrlnum3 value="1">
				<input type=hidden name=ctrlcount3 value="">
				<input type=hidden name=num3 value="1">
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tfz3_class_count name=tfz3_class_count size=2 onchange="call add_button_FA3(me.value)">類
				<input type="text" name=tfz3_class  id=tfz3_class readonly>
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" style="cursor:hand" >類別1：</td>		
			<td class="whitetablebg" colspan="7">第<INPUT type="text" id=class31 name=class31 size=3 maxlength=3 onchange="call count_kind3(reg.class31.value,1)">類</td>		
		</tr>
		<tr style="height:107.6pt">
			<td class="lightbluetable" align="right" width="18%">商品名稱1：</td>			
			<td class="whitetablebg" colspan="7"><textarea NAME="good_name31" ROWS="10" COLS="75" onchange="call good_name_count('good_name31','good_count31')"></textarea><br>共<input type="text" name=good_count31 size=2>項</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">商品群組代碼1：</td>
			<td class="whitetablebg" colspan="7"><textarea NAME=grp_code31 ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		</tr>
		</table>
</script>
<script type="text/html" id="br1_B">
	<!--FAB類別畫面-->
		<TABLE id=tabbrB name=tabbrB style="display:none" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p3Good)"><strong>伍、<u>團體標章表彰之內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" STYLE="cursor:hand;COLOR:BLUE"">表彰：</td>
			<td class="whitetablebg" colspan="7">
			<input type="text" name="tfb3_good_name" ID="tfb3_good_name" size=60 value="">會員之會籍。（填寫申請人名稱）
			<input type="hidden" name="tfz3_good_name" ID="tfz3_good_name">
			</td>
		</tr>	
		</table>
</script>
<script type="text/html" id="br1_F">
	<!--FAF類別畫面-->
		<TABLE id=tabbrF name=tabbrF style="display:none" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p4Good)"><strong>陸、<u>標章證明標的及內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" >一、證明標的：</td>
			<td class="whitetablebg" colspan="7">
			<input TYPE="radio" NAME="pul_F" ID="pul_F" value="3">商品
			<input TYPE="radio" NAME="pul_F" ID="pul_F" value="4">服務
			<input TYPE="hidden" NAME="tfz3_pul" ID="tfz3_pul">
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" >二、證明內容：</td>
			<td class="whitetablebg" colspan="7">
			<input type="test" name="tff3_good_name" ID="tff3_good_name" size=50>
			</td>
		</tr>	
		</table>
</script>

<script type="text/html" id="br1_4">
	<!--FA4,FA8,ijk類別畫面-->
		<TABLE id=tabbr4 name=tabbr4 style="display:" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class=lightbluetable colspan=8 valign=top STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(a3Good)"><strong>陸、<U>指定使用商品／服務類別及名稱</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" >類別種類：</td>
			<td class="whitetablebg" colspan="7" >
				<input type="radio" id=tfz4_class_type name=tfz4_class_type value="int">國際分類
				<input type="radio" id=tfz4_class_type name=tfz4_class_type value="old" disabled>舊類
			</td>
		</tr>
		<tr>	
			<td class="lightbluetable" align="right" title="請輸入類別，並以逗號分開(例如：1,5,32)。">類別項目：</td>
				<input type=hidden name=ctrlnum4 value="1">
				<input type=hidden name=ctrlcount4 value="">
				<input type=hidden name=num4 value="1">
			<td class="whitetablebg" colspan="7" >共<input type="text" id=tfz4_class_count name=tfz4_class_count size=2 onchange="call add_button_FA4(me.value)">類
				<input type="text" name=tfz4_class  id=tfz4_class readonly>
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" style="cursor:hand" >類別1：</td>		
			<td class="whitetablebg" colspan="7">第<INPUT type="text" id=class41 name=class41 size=3 maxlength=3 onchange="call count_kind4(reg.class41.value,1)">類</td>		
		</tr>
		<tr style="height:107.6pt">
			<td class="lightbluetable" align="right" width="18%">商品名稱1：</td>			
			<td class="whitetablebg" colspan="7"><textarea NAME="good_name41" ROWS="10" COLS="75" onchange="call good_name_count('good_name41','good_count41')"></textarea><br>共<input type="text" name=good_count41 size=2>項</td>
		</tr>		
		<tr>
			<td class="lightbluetable" align="right">商品群組代碼1：</td>
			<td class="whitetablebg" colspan="7"><textarea NAME=grp_code41 ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		</tr>
		</table>
</script>
<script type="text/html" id="br1_C">
	<!--FAC類別畫面-->
		<TABLE id=tabbrC name=tabbrC style="display:none" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p3Good)"><strong>伍、<u>團體標章表彰之內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" STYLE="cursor:hand;COLOR:BLUE"">表彰：</td>
			<td class="whitetablebg" colspan="7">
			<input type="text" name="tfc4_good_name" ID="tfc4_good_name" size=60 value="">會員之會籍。（填寫申請人名稱）
			<input type="hidden" name="tfz4_good_name" ID="tfz4_good_name">
			</td>
		</tr>	
		</table>
</script>
<script type="text/html" id="br1_G">
	<!--FAG類別畫面-->
		<TABLE id=tabbrG name=tabbrG style="display:none" border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:hand;COLOR:BLUE" ONCLICK="PMARK(p4Good)"><strong>陸、<u>標章證明標的及內容</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">一、證明標的：</td>
			<td class="whitetablebg" colspan="7">
			<input TYPE="radio" NAME="pul_G" ID="pul_G" value="3">商品
			<input TYPE="radio" NAME="pul_G" ID="pul_G" value="4">服務
			<input TYPE="hidden" NAME="tfz4_pul" ID="tfz4_pul">
			</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right">二、證明內容：</td>
			<td class="whitetablebg" colspan="7">
			<input type="test" name="tfg4_good_name" ID="tfg4_good_name" size=50>
			</td>
		</tr>	
		</table>
</script>

<uc1:br_A1_remark1 runat="server" ID="br_A1_remark1" />
<!--include file="../commonForm/br_A1_remark1.ascx"--><!--附件様版-->

<script language="javascript" type="text/javascript">
    var br_remark1_form = {};
    br_remark1_form.init = function () {
    }

    br_remark1_form.CopyStr = function () {
        var strRemark1 = "";
        $("#br_remark1 :checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val() + "|";
            }
        });
        //其他文件輸入框
        $("#br_remark1 :text").each(function (index) {
            var $this = $(this);
            if ($this.val() != "") {
                strRemark1 += "Z9-" + $this.val() + "-Z9|";
            }
        });
        reg.tfz_remark1.value = strRemark1;
    }
</script>
