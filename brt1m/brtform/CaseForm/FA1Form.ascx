﻿<%@ Control Language="C#" ClassName="FA1Form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/brt1m/brtform/CaseForm/FA1Form_remark1.ascx" TagPrefix="uc1" TagName="FA1Form_remark1" %>


<script runat="server">
    //新申請案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected string SQL = "";

    protected string tfz1_agt_no="",tfz_country = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //代理人
        tfz1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        //語文別/國家
        tfz_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        
        if (prgid.ToLower() == "brt51") {//程序客收確認
            Lock["brt51"] = "Lock";
        }
        if (prgid.ToLower() == "brt52") {//交辦維護
            Lock["brt52"] = "Lock";
            Hide["brt52"] = "Hide";
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<INPUT TYPE=hidden id=tfz1_S_Mark NAME=tfz1_S_Mark value="">
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr id="showseq1">
		<td class=lightbluetable align=right width="10%" >案件編號：</td>
		<td class=whitetablebg colspan=7>
			<INPUT TYPE=text id=tfz1_seq NAME=tfz1_seq SIZE=<%=Sys.DmtSeq%> MAXLENGTH=<%=Sys.DmtSeq%> readonly class="SEdit">-
            <%if(Lock.TryGet("brt52")!="Lock"){%>
			    <select id=tfz1_seq1 name=tfz1_seq1 onchange="br_form.seq1_conctrl()" class="<%#Lock.TryGet("brt51")%>">
			        <option value="_">一般</option>
			        <option value="M">M_大陸案</option>
			    </select>
            <%}else{%>
                <INPUT TYPE=text NAME=tfz1_seq1 id=tfz1_seq1 SIZE=<%=Sys.DmtSeq1%> MAXLENGTH=<%=Sys.DmtSeq1%> style="text-transform:uppercase;" class="<%#Lock.TryGet("brt52")%>">	
            <%}%>
		</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right" width="10%" rowspan=2>商標種類：</td>
		<td class="whitetablebg" colspan=7>
            <input type="radio" name="span_mark1" value="" disabled>商標
            <input type="radio" name="span_mark1" value="N" disabled>團體商標
            <input type="radio" name="span_mark1" value="M" disabled>團體標章
            <input type="radio" name="span_mark1" value="L" disabled>證明標章
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
            <select id="tfz1_agt_no" NAME="tfz1_agt_no"><%#tfz1_agt_no%></select>
		</td>
	</tr>
    <!--壹、商標圖樣-->
    <tr class='sfont9'>
        <td colspan=8 id="td_br_appl">
        </td>
    </tr>
    <!--貳、優先權聲明-->
    <tr>
	    <td colspan=8 class="whitetablebg">
	        <TABLE border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
                <tr>
	                <td class="lightbluetable" colspan="4" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(ztextp)"><strong>貳、<u>優先權聲明</u></strong></td>
                </tr>
                <tr>
	                <td class="lightbluetable" align="right">申請日：</td>
	                <td class="whitetablebg">
                        <input TYPE="text" id="pfz1_prior_date" NAME="pfz1_prior_date" SIZE="10" class="dateField">
	                </TD>
	                <td class="lightbluetable" align="right">首次申請國家：</td>
	                <td class="whitetablebg">
                        <select id="tfz1_prior_country" NAME="tfz1_prior_country"><%#tfz_country%></select>
		                申請案號：<input type="text" id=tfz1_prior_no name=tfz1_prior_no size=20 maxlength="20">
	                </td>
                </tr>
            </table>
	    </td>	
    </tr>
    <!--參、展覽會優先權聲明 依案性第3碼切換顯示-->
    <!--tr class="tabbrshow_0 tabbrshow_1 tabbrshow_2 tabbrshow_3 tabbrshow_4 tabbrshow_5 tabbrshow_6 tabbrshow_7 tabbrshow_8 tabbrshow_D tabbrshow_E tabbrshow_F tabbrshow_I tabbrshow_J tabbrshow_K">
	    <td colspan=8 class="whitetablebg">
	    </td>	
    </tr-->
    <tr class='sfont9'>
        <td colspan=8 id="td_br_show">
        </td>
    </tr>
    <!--伍、團體標章表彰之內容 依案性第3碼切換顯示-->
    <!--tr class="tabbrgood_0 tabbrgood_9 tabbrgood_A tabbrgood_B tabbrgood_C">
	    <td colspan=8 class="whitetablebg">
	    </td>	
    <tr-->
    <tr class='sfont9'>
        <td colspan=8 id="td_br_good">
        </td>
    </tr>
    <!--陸、標章證明標的及內容 依案性第3碼切換顯示-->
    <!--tr class="tabbrgood_0 tabbrgood_D tabbrgood_E tabbrgood_F tabbrgood_G">
	    <td colspan=8 class="whitetablebg">
	    </td>	
    </tr-->
    <!--陸、指定使用商品／服務類別及名稱 依案性第3碼切換顯示-->
    <!--tr class="tabbrclass_0 tabbrclass_1 tabbrclass_2 tabbrclass_3 tabbrclass_4 tabbrclass_5 tabbrclass_6 tabbrclass_7 tabbrclass_8 tabbrclass_I tabbrclass_J tabbrclass_K">
	    <td colspan=8 class="whitetablebg">
	    </td>	
    </tr-->
    <tr class='sfont9'>
        <td colspan=8 id="td_br_class">
        </td>
    </tr>
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top"><strong>柒、簽章及具結：</strong></td>
    </tr>	
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top" >備註：本案另涉有他案時，請於備註欄內填明。</td>
    </tr>			
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top"><INPUT type="radio" id="ttz1_R1Code" name="ttz1_RCode" value="R1" onclick="br_form.CopyStr1(reg.tfz1_remark2,'1',this)">本案需俟註冊第<input TYPE="text" id="ttz1_R1" NAME="ttz1_R1" SIZE="10" MAXLENGTH="50" onchange="br_form.CopyStr1(reg.tfz1_remark2,'0',this)">號商標爭議案確定後，再行審理。</td>
    </tr>	
    <tr>
	    <td class="lightbluetable" colspan="8" valign="top"><INPUT type="radio" id="ttz1_R9Code" name="ttz1_RCode" value="R9" onclick="br_form.CopyStr1(reg.tfz1_remark2,'1',this)">其他<input TYPE="text" id="ttz1_R9" NAME="ttz1_R9" SIZE="50" onchange="br_form.CopyStr1(reg.tfz1_remark2,'0',this)">
	    <input TYPE="hidden" id="tfz1_remark2" NAME="tfz1_remark2" value="">
	    </td>
    </tr>
    <tr>
        <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a5Attech)">
            <strong><u>附件：</u></strong>
            <input type="hidden" id="tfz1_remark1" name="tfz1_remark1">
        </td>
    </tr>
    <tr class='sfont9'>
        <td colspan=8 id="td_br_remark1"></td>
    </tr>
</TABLE>

<!--壹、商標圖樣 様版 依案性第3碼切換顯示-->
<script type="text/html" class="tabbr_appl_0 tabbr_appl_1 tabbr_appl_5 tabbr_appl_9 tabbr_appl_D">
	<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%"><!--1-->
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="10%"><strong>壹、<span class="txtMark0"></span>圖樣</strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" STYLE="cursor:pointer;COLOR:BLUE" align=right ID="nAppend" onclick="PMARK(p1Appl_name)">一、<u><span class="txtMark1"></span>名稱：</u></td>
		<td class="whitetablebg" colspan=7>
            <input TYPE="text" id="tfz1_Appl_name" NAME="tfz1_Appl_name" alt="『商標(標章)名稱』" SIZE="60" MAXLENGTH="100" onblur="appl_name_watch(this)">
			<input TYPE="hidden" id="file1" name="file1" value="">
	        <input TYPE="text" id="Draw_file1" name="Draw_file1" SIZE="50" maxlength="50" readonly>	    
			<input type="button" class="cbutton" id="butUpload1" name="butUpload1"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo()" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo()" >
            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo()" >
	    </td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p1Color)"><u>二、圖樣顏色：</u></td>
		<td class="whitetablebg" colspan="7">
		    <input TYPE="radio" NAME="tfz1_color" ID="tfz1_colorB" value="B">墨色
		    <input TYPE="radio" NAME="tfz1_color" ID="tfz1_colorC" value="C">彩色
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(p1Oappl_name)"><u>三、聲明不專用：</u></td>
		<td class="whitetablebg" colspan=7><input TYPE="text" id="tfz1_Oappl_name" NAME="tfz1_Oappl_name" SIZE="60" alt="『不主張專用』" MAXLENGTH="100" onblur="fDataLen(this)"></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a1Eappl_name)">四、<u><span class="txtMark1"></span>圖樣分析</u></td>
	</tr>			
	<tr>
		<td class="lightbluetable" align="right" >中文：</td>
		<td class="whitetablebg" colspan="7"><input TYPE="text" id="tfz1_Cappl_name" NAME="tfz1_Cappl_name" SIZE="50" alt="『商標圖樣分析中文』" MAXLENGTH="100" onblur="fDataLen(this)"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >外文：</td>
		<td class="whitetablebg" colspan="7">
		<input TYPE="text" id="tfz1_Eappl_name" NAME="tfz1_Eappl_name" SIZE="30" alt="『商標圖樣分析外文』" MAXLENGTH="100" onblur="fDataLen(this)">　語文別：
        <select id="tfz1_Zname_type" NAME="tfz1_Zname_type"><%#tfz_country%></select><br>
		中文字義：<input TYPE="text" id="tfz1_Eappl_name1" NAME="tfz1_Eappl_name1" SIZE="30" MAXLENGTH="100" alt="『圖樣分析英文~中文字義』"  onblur="fDataLen(this)">
		<span style="display:none">　讀音：<input TYPE="text" id="tfz1_Eappl_name2" NAME="tfz1_Eappl_name2" SIZE="30" MAXLENGTH="100" alt="『圖樣分析英文~讀音』"  onblur="fDataLen(this)"></span>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >圖形：</td>
		<td class="whitetablebg" colspan="7"><input TYPE="text" id="tfz1_Draw" NAME="tfz1_Draw" SIZE="30" MAXLENGTH="50"></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >記號：</td>
		<td class="whitetablebg" colspan="7"><input TYPE="text" id="tfz1_Symbol" NAME="tfz1_Symbol" SIZE="30" MAXLENGTH="50"></td>
	</tr>
    </TABLE>
</script>

<script type="text/html" class="tabbr_appl_2 tabbr_appl_6 tabbr_appl_A tabbr_appl_E">
	<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%"><!--2-->
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="10%"><strong>壹、<span class="txtMark1"></span>圖樣</strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" STYLE="cursor:pointer;COLOR:BLUE" align=right ID="nAppend" onclick="PMARK(p1Appl_name)">一、<u><span class="txtMark1"></span>名稱：</u></td>
		<td class="whitetablebg" colspan=7>
            <input TYPE="text" id="tfz1_Appl_name" NAME="tfz1_Appl_name" alt="『商標(標章)名稱』" SIZE="60" MAXLENGTH="100" onblur="appl_name_watch(this)">
			<input TYPE="hidden" id="file1" name="file1" value="">
	        <input TYPE="text" id="Draw_file1" name="Draw_file1" SIZE="50" maxlength="50" readonly>	    
			<input type="button" class="cbutton" id="butUpload1" name="butUpload1"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo()" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo()" >
            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo()" >
	    </td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" >二、商標圖樣顏色：</td>
		<td class="whitetablebg" colspan="7"><INPUT TYPE=text id=tfz1_colorM NAME=tfz1_color value="M">彩色</td>
	</tr>		
	<tr>
		<td class="lightbluetable" align="right" >三、聲明不專用：</td>
		<td class="whitetablebg" colspan=7><input TYPE="text" id="tfz1_Oappl_name" NAME="tfz1_Oappl_name" SIZE="60" alt="『不主張專用』" MAXLENGTH="100" onblur="fDataLen(this)"></td>
	</tr>
	<tr>
		<td class=lightbluetable colspan=8 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p5Remark1)">五、<U><span class="txtMark1"></span>描述：</u>（色彩種類、明度、漸層及顏色實際使用於商品、包裝、容器、營業相關物品之特殊方式、位置、內容等請詳細說明）</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >(一)：</td>
		<td class=whitetablebg colspan=7>本件為顏色<span class="txtMark0"></span>，圖樣上虛線部分之<span id=span_FA151></span>之一部份。
		</TD>
	</TR>	
	<tr>
		<td class=lightbluetable align=right >(二)：</td>
		<td class=whitetablebg colspan=7>
		(請從此處開始描述，指明顏色並說明其使用於<span id=span_FA152></span>之情形)：<br>
		<TEXTAREA id=tfz1_Remark4 NAME=tfz1_Remark4 ROWS=2 COLS=60></TEXTAREA></TD>
	</TR>	
    </TABLE>
</script>

<script type="text/html" class="tabbr_appl_3 tabbr_appl_7 tabbr_appl_B tabbr_appl_F">
	<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%"><!--3-->
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="10%"><strong>壹、<span class="txtMark1"></span>圖樣(本<span class="txtMark1"></span>以五線譜、簡譜或表現該聲音之說明齊備之日為申請日)</strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" STYLE="cursor:pointer;COLOR:BLUE" align=right ID="nAppend" onclick="PMARK(a3Appl_name)">一、<u><span class="txtMark1"></span>名稱：</u></td>
		<td class=whitetablebg colspan=7>
		<INPUT TYPE=text id=tfz1_Appl_name NAME=tfz1_Appl_name SIZE=60 MAXLENGTH=100 alt="『商標(標章)名稱』" onblur="appl_name_watch(this)">
	</tr>
	<tr>
		<td class=lightbluetable align=right STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a3Draw)">二、<u><span class="txtMark1"></span>圖樣：</u></td>
		<TD class=whitetablebg colspan=7>
			<input TYPE="hidden" id="file1" name="file1" value="">
	        <input TYPE="text" id="Draw_file1" name="Draw_file1" SIZE="50" maxlength="50" readonly>	    
			<input type="button" class="cbutton" id="butUpload1" name="butUpload1"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo()" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo()" >
            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo()" >
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right><input type="radio" name=tfz1_remark3 value="Y"></td>
		<td class=lightbluetable colspan=7>１、<span class="txtMark1"></span>圖樣為表現該聲音之五線譜或簡譜。（仍應於「三、<span class="txtMark1"></span>描述」簡要說明）</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right><input type="radio" name=tfz1_remark3 value="N"></td>
		<td class=lightbluetable colspan=7>２、無法以五線譜或簡譜表現該聲音者，<span class="txtMark1"></span>圖樣得為該聲音之文字說明。（請於「三、<span class="txtMark1"></span>描述」詳細說明）</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a3Remark1)">三、<U><span class="txtMark1"></span>描述及樣本：</U></td>
		<td class=whitetablebg colspan=7>
		<TEXTAREA id=tfz1_Remark4 NAME=tfz1_Remark4 ROWS=2 COLS=60></TEXTAREA></TD>
	</TR>	
    </TABLE>
</script>

<script type="text/html" class="tabbr_appl_4 tabbr_appl_8 tabbr_appl_C tabbr_appl_G tabbr_appl_I tabbr_appl_J tabbr_appl_K">
	<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%"><!--4-->
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="10%"><strong>壹、<span class="txtMark0"></span>圖樣</strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" STYLE="cursor:pointer;COLOR:BLUE" align=right ID="nAppend" onclick="PMARK(p1Appl_name)">一、<u><span class="txtMark1"></span>名稱：</u></td>
		<td class="whitetablebg" colspan=7>
            <input TYPE="text" id="tfz1_Appl_name" NAME="tfz1_Appl_name" alt="『商標(標章)名稱』" SIZE="60" MAXLENGTH="100" onblur="appl_name_watch(this)">
			<input TYPE="hidden" id="file1" name="file1" value="">
	        <input TYPE="text" id="Draw_file1" name="Draw_file1" SIZE="50" maxlength="50" readonly>	    
			<input type="button" class="cbutton" id="butUpload1" name="butUpload1"  value="商標圖檔上傳" onclick="br_form.UploadAttach_photo()" >
		    <input type="button" class="redbutton" id="btnDelAtt" name="btnDelAtt"  value="商標圖檔刪除" onclick="br_form.DelAttach_photo()" >
            <input type="button" class="cbutton" id="btnDisplay" name="btnDisplay" value="商標圖檔檢視" onclick="br_form.PreviewAttach_photo()" >
	    </td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a4Color)">二、<u>圖樣顏色：</u></td>
		<td class="whitetablebg" colspan="7">
		    <input TYPE="radio" NAME="tfz1_color" ID="tfz1_colorB" value="B">墨色
		    <input TYPE="radio" NAME="tfz1_color" ID="tfz1_colorC" value="C">彩色
		</td>
	</tr>		
	<tr>
		<td class="lightbluetable" align="right">三、聲明不專用：</td>
		<td class="whitetablebg" colspan=7><input TYPE="text" id="tfz1_Oappl_name" NAME="tfz1_Oappl_name" SIZE="60" alt="『不主張專用』" MAXLENGTH="100" onblur="fDataLen(this)"></td>
	</tr>

		<tr  style="display:none">
			<td class=lightbluetable align=right>四、<span class="txtMark0"></span>圖樣：</td>
			<td class=lightbluetable colspan=7>商標圖樣為表現立體形狀之視圖，得以虛線表現立體形狀使用於指定商品或服務之方式、位置或內容態樣。
                <input type="hidden" id="tfz1_remark3" name="tfz4_remark3">
			</td>
		</tr>
		<tr  style="display:none">
			<td class=lightbluetable align=right><input type="checkbox" id=tt44_M  name=tt44 value="M" onclick="br_form.CopyStr('input[name=tt44]',reg.tfz1_remark3)"></td>
			<td class=lightbluetable colspan=7 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a4Remark3M)">
                <u>主要立體圖</u></td>
		</tr>
		<tr  style="display:none">
			<td class=lightbluetable align=right><input type="checkbox" id=tt44_O name=tt44 value="O" onclick="br_form.CopyStr('input[name=tt44]',reg.tfz1_remark3)"></td>
			<td class=lightbluetable colspan=7 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a4Remark3O)">
            <u>其他角度圖：</u>若立體形狀因各角度特徵不同，除第一個視圖外，得另檢附五個以下其他角度之視圖。
			</td>
		</tr>


	<tr>
		<td class=lightbluetable colspan=8 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a4Remark1)">五、<U><span class="txtMark1"></span>描述<span id=span_FA150></span>：</u>(<span id=span_FA151></span>)</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan=7>			
		<TEXTAREA id=tfz1_Remark4 NAME=tfz1_Remark4 ROWS=2 COLS=60></TEXTAREA></TD>
	</TR>	
    </TABLE>
</script>
<!--參、展覽會優先權聲明 依案性第3碼切換顯示-->
<script type="text/html" class="tabbrshow_0 tabbrshow_1 tabbrshow_2 tabbrshow_3 tabbrshow_4 tabbrshow_5 tabbrshow_6 tabbrshow_7 tabbrshow_8 tabbrshow_D tabbrshow_E tabbrshow_F tabbrshow_I tabbrshow_J tabbrshow_K">
	<input type=hidden id=shownum name=shownum value="0">
	<TABLE id=tabshow border=0 cellspacing=1 cellpadding=2 width="100%" class="bluetable tabbrshow_1 tabbrshow_2 tabbrshow_3 tabbrshow_4 tabbrshow_5 tabbrshow_6 tabbrshow_7 tabbrshow_8 tabbrshow_D tabbrshow_E tabbrshow_F tabbrshow_I tabbrshow_J tabbrshow_K">
        <thead>
		<tr>
			<td class="lightbluetable" colspan="3" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ><strong>參、<u>展覽會優先權聲明</u></strong></td>
		</tr>
		<TR class=whitetablebg align=center>
			<TD colspan=3 >
				<input type=button value ="增加一筆展覽會優先權" class="cbutton" id=show_Add_button name=show_Add_button_FA1 onclick="br_form.add_show()">			
				<input type=button value ="減少一筆展覽會優先權" class="cbutton" id=show_Del_button name=show_Del_button_FA1 onclick="br_form.del_show()">
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
		            <input type=text size=10 maxlength=10 id='show_date_##' name='show_date_##' onblur="br_form.chk_showdate('##')" class="dateField">
		        </td>
		        <td class=whitetablebg align=center>
		            <input type=text id='show_name_##' name='show_name_##' size=50 maxlength=100>
		        </td>
	        </tr>
        </script>
	</table>
</script>
<!--伍、團體標章表彰之內容 依案性第3碼切換顯示-->
<script type="text/html" class="tabbrgood_9 tabbrgood_A tabbrgood_B tabbrgood_C">
	<TABLE border=0 cellspacing=1 cellpadding=2 width="100%" class="bluetable tabbrgood_9 tabbrgood_A tabbrgood_B tabbrgood_C">
		<tr>
			<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p3Good)"><strong>伍、<u>團體標章表彰之內容</u></strong></td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right" STYLE="cursor:pointer;COLOR:BLUE">表彰：</td>
			<td class="whitetablebg" colspan="7">
			    <input type="text" name="tf91_good_name" ID="tf91_good_name" size=60 value="">會員之會籍。（填寫申請人名稱）
		        <input type="hidden" name="tfz1_good_name" ID="tfz1_good_name" size=50>
			</td>
		</tr>	
	</table>
</script>
<!--陸、標章證明標的及內容 依案性第3碼切換顯示-->
<script type="text/html" class="tabbrgood_D tabbrgood_E tabbrgood_F tabbrgood_G">
    <TABLE border=0 cellspacing=1 cellpadding=2 width="100%" class="bluetable tabbrgood_D tabbrgood_E tabbrgood_F tabbrgood_G">
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p4Good)"><strong>陸、<u>標章證明標的及內容</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">一、證明標的：</td>
		<td class="whitetablebg" colspan="7">
		<input TYPE="radio" NAME="pul" value="3">商品
		<input TYPE="radio" NAME="pul" value="4">服務
		<input TYPE="text" NAME="tfz1_pul" ID="tfz1_pul">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right">二、證明內容：</td>
		<td class="whitetablebg" colspan="7">
		    <input type="text" name="tfd1_good_name" ID="tfd1_good_name" size=50>
		    <input type="hidden" name="tfz1_good_name" ID="tfz1_good_name" size=50>
		</td>
	</tr>	
	</table>
</script>
<!--陸、指定使用商品／服務類別及名稱 依案性第3碼切換顯示-->
<script type="text/html" class="tabbrclass_0 tabbrclass_1 tabbrclass_2 tabbrclass_3 tabbrclass_4 tabbrclass_5 tabbrclass_6 tabbrclass_7 tabbrclass_8 tabbrclass_I tabbrclass_J tabbrclass_K">
	<TABLE border=0 id="tabbr1" cellspacing=1 cellpadding=2 width="100%" class="bluetable tabbrclass_1 tabbrclass_2 tabbrclass_3 tabbrclass_4 tabbrclass_5 tabbrclass_6 tabbrclass_7 tabbrclass_8 tabbrclass_I tabbrclass_J tabbrclass_K">
        <thead>
		    <tr>
			    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p1Good)"><strong>陸、<u>指定使用商品／服務類別及名稱</u></strong></td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right" >類別種類：</td>
			    <td class="whitetablebg" colspan="7" >
				    <input type="radio" id=tfz1_class_typeI name=tfz1_class_type value="int">國際分類
				    <input type="radio" id=tfz1_class_typeO name=tfz1_class_type value="old" disabled>舊類
			    </td>
		    </tr>
		    <tr>	
			    <td class="lightbluetable" align="right" title="請輸入類別，並以逗號分開(例如：1,5,32)。">類別項目：</td>
			    <td class="whitetablebg" colspan="7" >共<input type="text" id=tfz1_class_count name=tfz1_class_count size=2 onchange="br_form.Add_class(this.value)">類
				    <input type=hidden id=num1 name=num1 value="0"><!--畫面上有幾筆-->
				    <input type=hidden id=ctrlnum1 name=ctrlnum1 value="0">
				    <input type=hidden id=ctrlcount1 name=ctrlcount1 value="">
				    <input type="text" id=tfz1_class name=tfz1_class style="width:70%" readonly>
			    </td>
		    </tr>
        </thead>
        <tbody></tbody>
        <script type="text/html" id="class_template"><!--類別樣板-->
		    <tr class="tr_class_##">
			    <td class="lightbluetable" align="right" style="cursor:pointer" >類別##：</td>
			    <td class="whitetablebg" colspan="7">第<INPUT type="text" id=class1_## name=class1_## size=3 maxlength=3 onchange="br_form.count_kind('##')">類</td>		
		    </tr>
		    <tr class="tr_class_##" style="height:107.6pt">
			    <td class="lightbluetable" align="right" width="18%">商品名稱##：</td>
			    <td class="whitetablebg" colspan="7">
                    <textarea id="good_name1_##" NAME="good_name1_##" ROWS="10" COLS="75" onchange="br_form.good_name_count('##')"></textarea>
                    <br>共<input type="text" id=good_count1_## name=good_count1_## size=2>項</td>
		    </tr>
		    <tr class="tr_class_##">
			    <td class="lightbluetable" align="right">商品群組代碼##：</td>
			    <td class="whitetablebg" colspan="7"><textarea id=grp_code1_## NAME=grp_code1_## ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		    </tr>
        </script>
	</table>
</script>

<uc1:FA1Form_remark1 runat="server" ID="FA1Form_remark1" /><!--附件様版 依案性第3碼切換顯示-->

<script language="javascript" type="text/javascript">
    var br_form = {};
    //br_form.init = function () {}

    //展覽優先權增加一筆
    br_form.add_show = function () {
        var nRow = parseInt($("#shownum").val(), 10) + 1;
        //複製樣板
        var copyStr = $("#show_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabshow tbody").append(copyStr);
        $("#shownum").val(nRow);
        $(".dateField", $('#tr_show_' + nRow)).datepick();
    }

    //展覽優先權減少一筆
    br_form.del_show = function () {
        var nRow = CInt($("#shownum").val());
        $('#tr_show_' + nRow).remove();
        $("#shownum").val(Math.max(0, nRow - 1));
    }

    //檢查展覽優先權日期
    br_form.chk_showdate = function (pno) {
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

    //*****共N類
    br_form.Add_class = function (classCount) {
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

    //依商品名稱計算類別
    br_form.good_name_count = function (nRow) {
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

    //檢查類別範圍0~45
    br_form.checkclass = function (xclass) {
        if (CInt(xclass) < 0 || CInt(xclass) > 45) {
            alert("商品類別需介於1~45之間,請重新輸入。");
            return false;
        }
    }

    //類別串接
    br_form.count_kind = function (nRow) {
        if ($("#class1_" + nRow).val() != "") {
            if (IsNumeric($("#class1_" + nRow).val())) {
                var x = ("000" + $("#class1_" + nRow).val()).Right(3);//補0
                $("#class1_" + nRow).val(x);
                br_form.checkclass(x);
            } else {
                alert("商品類別請輸入數值!!!");
                $("#class1_" + nRow).val("");
            }
        }

        var nclass = $("#tabbr1>tbody input[id^='class1_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        });
        $("#tfz1_class").val(nclass.get().join(','));
        $("#tfz1_class_count").val(Math.max(CInt($("#tfz1_class_count").val()), nclass.length));//回寫共N類
    }


    //**簽章及具結
    br_form.CopyStr1 = function (x, y, o) {
        //x=要丟值的欄位reg.tfz1_remark2,y=1=radio 0=text,z=觸發的欄位
        x.value = "";
        if (y == "1") {//選radio時清空文字內容
            $("#ttz1_R1,#ttz1_R9").val("");
        }
        if (y == "0") {
            var id=$(o).attr("id");
            if (o.value != "") {
                //$("#" + id + "Code").prop("checked", true);
                var j = $("#" + id + "Code").val() || "";
                x.value = j + "|" + o.value + "|";
            }
        }
    }

    //附件
    br_form.AttachStr = function () {
        var strRemark1 = "";
        $("#td_br_remark1 :checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val()
                //其他文件輸入框
                if ($("#tt11_" + $this.val() + "t").length > 0) {
                    if ($("#tt11_" + $this.val() + "t").val() != "") {
                        strRemark1 += "|Z9-" + $("#tt11_" + $this.val() + "t").val() + "-Z9";
                    }
                }
                strRemark1 += "|";
            }
        });
        reg.tfz1_remark1.value = strRemark1;
    }

    br_form.CopyStr = function (selector,tar) {
        var strRemark1 = "";
        $(selector).each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val() + "|";
            }
        });
        tar.value = strRemark1;
    }

    var old_ar_mark = "";
    br_form.seq1_conctrl = function () {
        if ($("#tfy_Arcase").val() != "") {
            if ($("#tfz1_seq1").val() == "M") {
                $("#tfy_Ar_mark").val("X");//請款註記:大陸進口案
                old_ar_mark = "X";
            } else {
                if (old_ar_mark == "X") {
                    $("#tfy_Ar_mark").val("");
                    old_ar_mark = "";
                }
            }
        } else {
            alert("請選擇交辦案性!!");
            settab("#case");
            $("#tfy_Arcase").focus();
        }
    }

    //商標圖檔上傳
    br_form.UploadAttach_photo = function () {
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
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //商標圖檔刪除
    br_form.DelAttach_photo = function () {
        if ($("#Draw_file1").val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if ($("#draw_attach_file").val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if (confirm("確定刪除上傳圖檔？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&btnname=butUpload1",
                data: { draw_file: $("#draw_attach_file").val() },
                type: 'GET',
                dataType: "script",
                async: false,
                cache: false,
                success: function (data) {
                    $("#draw_attach_file").val("");
                    $("#Draw_file1").val("");
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });

            //var url = getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&draw_file=" + $("#draw_attach_file").val() + "&btnname=butUpload1";
            //window.open(url, "myWindowOneN", "width=700 height=600 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //$("#draw_attach_file").val("");
            //$("#Draw_file1").val("");
        }
    }

    //商標圖檔檢視
    br_form.PreviewAttach_photo = function () {
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

    //交辦內容綁定
    br_form.bind = function () {
        //console.log("br_form.bind");
        if (jMain.case_main.length == 0) {
            //　類別種類
            $("#tfz1_class_typeI").prop("checked", true);
        } else {
            $("#tfz1_Appl_name").val(jMain.case_main[0].appl_name);//*商標名稱
            $("#tfz1_cust_prod").val(jMain.case_main[0].cust_prod);//20180301增加客戶卷號
            $("#tfz1_Oappl_name").val(jMain.case_main[0].oappl_name);//不單獨主張專用權
            $("#tfz1_Cappl_name").val(jMain.case_main[0].cappl_name);//商標圖樣中文
            $("#tfz1_Eappl_name").val(jMain.case_main[0].eappl_name);//商標圖樣外文
            $("#tfz1_Eappl_name1").val(jMain.case_main[0].eappl_name1);//圖樣分析中文字義
            $("#tfz1_Eappl_name2").val(jMain.case_main[0].eappl_name2);//圖樣分析讀音
            $("#tfz1_Zname_type").val(jMain.case_main[0].zname_type);//語文別
            $("#tfz1_Draw").val(jMain.case_main[0].draw);//圖形說明
            $("#tfz1_Symbol").val(jMain.case_main[0].symbol);//記號說明
            //if(main.formFunction=="Edit"){
            $("#Draw_file1").val(jMain.case_main[0].draw_file);//*圖檔實際路徑
            $("#file1").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
            $("#draw_attach_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
            if ($("#Draw_file1").val() != "") {
                $("#butUpload1").prop("disabled", true);
            }
            //}
            if (jMain.case_main[0].color == "B") {
                $("#tfz1_colorB").prop("checked", true);
            } else if (jMain.case_main[0].color == "C" || jMain.case_main[0].color == "M") {
                $("#tfz1_colorC").prop("checked", true);
            }

            //標章描述
            $("input[name=tfz1_remark3][value='" + jMain.case_main[0].remark3 + "'").prop("checked", true);
            //聲音/立體商標圖樣
            switch (jMain.case_main[0].arcase.substr(2, 1).toUpperCase()) {//案性第3碼
                case '4': case '8': case 'C': case 'G'://立體
                    if (jMain.case_main[0].remark3 != "") {
                        var arr_remark3 = jMain.case_main[0].remark3.split("|");
                        for (var i = 0; i < arr_remark3.length; i++) {
                            $("#tt44_" + arr_remark3[i]).prop("checked", true);
                        }
                    }
                    break;
                case '3': case '7': case 'B': case 'F'://聲音
                    if (jMain.case_main[0].remark3 == "Y") {
                        $("input[name=tfz1_remark3][value='Y']").prop("checked", true);
                    } else {
                        $("input[name=tfz1_remark3][value='N']").prop("checked", true);
                    }
                    break;
            }
            $("#tfz1_agt_no").val(jMain.case_main[0].agt_no);//*出名代理人代碼
            //**優先權聲明
            $("#pfz1_prior_date").val(dateReviver(jMain.case_main[0].prior_date, "yyyy/M/d"));
            $("#tfz1_prior_country").val(jMain.case_main[0].prior_country);
            $("#tfz1_prior_no").val(jMain.case_main[0].prior_no);
            //**類別種類
            $("input[name='tfz1_class_type'][value='" + jMain.case_main[0].class_type + "']").prop('checked', true).triggerHandler("click");
            //指定使用商品／服務類別
            if ($("#tabbr1").length > 0) {//有載入才要檢查
                if (jMain.case_good.length > 0) {
                    $("#tfz1_class").val(jMain.case_main[0].class);//*類別
                    $("#tfz1_class_count").val(jMain.case_good.length);//共N類
                    br_form.Add_class(jMain.case_good.length);//產生筆數
                    $.each(jMain.case_good, function (i, item) {
                        $("#class1_" + (i + 1)).val(item.class);//第X類
                        $("#good_count1_" + (i + 1)).val(item.dmt_goodcount);//共N項
                        $("#grp_code1_" + (i + 1)).val(item.dmt_grp_code);//商品群組代碼
                        $("#good_name1_" + (i + 1)).val(item.dmt_goodname);//商品名稱
                    });
                }
                br_form.count_kind(1);////類別串接
            }
            //**表彰之內容
            $("#tf91_good_name").val(jMain.case_main[0].good_name);
            //**證明標的
            $("input[name='pul'][value='" + jMain.case_main[0].pul + "']").prop('checked', true).triggerHandler("click");
            $("#tfz1_pul").val(jMain.case_main[0].pul);
            //**證明內容
            $("#tfd1_good_name").val(jMain.case_main[0].good_name);
            //**描述實際使用說明
            $("#tfz1_Remark4").val(jMain.case_main[0].remark4);
            //**展覽優先權資料
            $("#tabshow tbody").empty();
            $("#shownum").val(0);
            $.each(jMain.case_show, function (i, item) {
                br_form.add_show();//展覽優先權增加一筆
                $("#show_sqlno_" + (i + 1)).val(item.show_sqlno);//流水號
                $("#show_date_" + (i + 1)).val(dateReviver(item.show_date, "yyyy/M/d"));//展覽會優先權日
                $("#show_name_" + (i + 1)).val(item.show_name);//展覽會名稱
            });
            //**簽章及具結
            $("#tfz1_remark2").val(jMain.case_main[0].remark2);
            if (jMain.case_main[0].remark2 != "") {
                var arr_remark2 = jMain.case_main[0].remark2.split("|");
                $("#ttz1_" + arr_remark2[0] + "Code").prop('checked', true);
                if (arr_remark2.length > 1) {
                    $("#ttz1_" + arr_remark2[0]).val(arr_remark2[1]);
                }
            }
            //**附件
            $("#tfz1_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                    //var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                    var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                    if (substr != null) {
                        $("#tt11_Z9t").val(substr[1]);
                    } else {
                        $("#tt11_" + arr_remark1[i]).prop("checked", true);
                    }
                }
            }

            //**商標種類2
            $("input[name=tfz1_s_mark2][value='" + jMain.case_main[0].s_mark2 + "']").prop("checked", true);
            //if (jMain.case_main[0].s_mark2 == "H") {
            //    $("input[name=tfz1_s_mark2][value='H']").prop("checked", true);//位置
            //} else if (jMain.case_main[0].s_mark2 == "I") {
            //    $("input[name=tfz1_s_mark2][value='I']").prop("checked", true);//氣味
            //} else if (jMain.case_main[0].s_mark2 == "J") {
            //    $("input[name=tfz1_s_mark2][value='J']").prop("checked", true);//觸覺
            //}
        }
    }
</script>
