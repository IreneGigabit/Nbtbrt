<%@ Control Language="C#" ClassName="tran_A1_remark1" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<input type="text" id="tfz1_remark1" name="tfz1_remark1">
<input type="text" id="tfz2_remark1" name="tfz2_remark1">
<input type="text" id="tfz3_remark1" name="tfz3_remark1">
<input type="text" id="tfz4_remark1" name="tfz4_remark1">
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
<tr>
    <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(a5Attech)"><strong><u>附件：</u></strong></td>
</tr>
<tr>
    <td colspan=8 class="sfont9" id="tran_remark1">
    </td>
</tr>
</TABLE>

<script type="text/html" id="tran_remark1_1">
	<table id=tabrem1 name=tabrem1 border=0 class="bluetable" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="sfont9" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="sfont9" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt11_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="sfont9" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="sfont9" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt11_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="sfont9" colspan="7">委任書(<input TYPE="checkbox" NAME="tt11_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt11_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_5">
	<TABLE id=tabrem5 name=tabrem5 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt51_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt51_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt51_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tt51_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tt51_Z8C" value="Z8C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt51_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt51_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_d">
	<TABLE id=tabremD name=tabremD border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttd1_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="ttd1_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttd1_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="ttd1_Z6C" value="Z6C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="ttd1_Z8C" value="Z8C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttd1_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttd1_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_9">
	<TABLE id=tabrem9 name=tabrem9 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt91_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt91_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tt91_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tt91_Z6C" value="Z6C" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt91_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
			<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt91_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz1_remark1)"></td>
		</tr>
	</table>
</script>
<!------->
<script type="text/html" id="tran_remark1_2">
	<TABLE id=tabrem2 name=tabrem2 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt22_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt22_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt22_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt22_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt22_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_6">
	<TABLE id=tabrem6 name=tabrem6 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt62_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt62_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt62_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tt62_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tt62_Z8C" value="Z8C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt62_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt62_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_a">
	<TABLE id=tabremA name=tabremA border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tta2_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tta2_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tta2_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z61" value="Z61" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tta2_Z61C" value="Z61C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tta2_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tta2_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_e">
	<TABLE id=tabremE name=tabremE border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tte2_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tte2_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tte2_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tte2_Z6C" value="Z6C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z81" value="Z81" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tte2_Z81C" value="Z81C" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tte2_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tte2_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz2_remark1)"></td>
	</tr>
	</table>
</script>
<!------->
<script type="text/html" id="tran_remark1_3">
	<TABLE id=tabrem3 name=tabrem3 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。（商標圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">載有本件聲音之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt33_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt33_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt33_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt33_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt33_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_7">
	<TABLE id=tabrem7 name=tabrem7 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。（商標圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">載有本件聲音之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt73_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt73_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt73_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tt73_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tt73_Z8C" value="Z8C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt73_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt73_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_b">
	<TABLE id=tabremB name=tabremB border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。（標章圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">載有本件聲音標章之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttb3_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttb3_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="ttb3_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z61" value="Z61" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="ttb3_Z61C" value="Z61C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttb3_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttb3_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_f">
	<TABLE id=tabremF name=tabremF border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。（標章圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z10" value="Z10" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">載有本件聲音標章之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttf3_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="ttf3_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttf3_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="ttf3_Z6C" value="Z6C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z81" value="Z81" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="ttf3_Z81C" value="Z81C" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttf3_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttf3_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz3_remark1)"></td>
	</tr>
	</table>
</script>
<!------->
<script type="text/html" id="tran_remark1_4">
	<TABLE id=tabrem4 name=tabrem4 border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt44_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt44_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt44_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">不具功能性之證據資料。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt44_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt44_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_8">
	<TABLE id=tabrem8 name=tabrem8 border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tt84_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tt84_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tt84_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="tt84_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="tt84_Z8C" value="Z8C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">不具功能性之證據資料。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt84_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tt84_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_c">
	<TABLE id=tabremC name=tabremC border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttc4_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttc4_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="ttc4_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z61" value="Z61" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="ttc4_Z61C" value="Z61C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttc4_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttc4_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_g">
	<TABLE id=tabremG name=tabremG border=1 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttg4_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="ttg4_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z3" value="Z3" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z51" value="Z51" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttg4_Z5C" value="Z5C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z6" value="Z6" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" NAME="ttg4_Z6C" value="Z6C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z81" value="Z81" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" NAME="ttg4_Z81C" value="Z81C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z7" value="Z7" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z8" value="Z8" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttg4_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttg4_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
			
	</tr>
	</table>
</script>
		
<script type="text/html" id="tran_remark1_i">
	<TABLE id=tabremi name=tabremi border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z21" value="Z21" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標樣本。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="tti4_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="tti4_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="tti4_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tti4_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="tti4_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_j">
	<TABLE id=tabremj name=tabremj border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">個別圖像各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z21" value="Z21" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">存載動態商標之AVI或MPEG檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttj4_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="ttj4_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttj4_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttj4_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttj4_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tran_remark1_k">
	<TABLE id=tabremk name=tabremk border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z1" value="Z1" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z21" value="Z21" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">商標樣本。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z2" value="Z2" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" NAME="ttk4_Z2C" value="Z2C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z31" value="Z31" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" NAME="ttk4_Z31C" value="Z31C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z4" value="Z4" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" NAME="ttk4_Z4C" value="Z4C" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)">附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z5" value="Z5" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttk4_Z9" value="Z9" onclick="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttk4_Z9t" SIZE="50" onchange="tran_remark1_form.CopyStr(reg.tfz4_remark1)"></td>
	</tr>
	</table>
</script>

<script language="javascript" type="text/javascript">
    var tran_remark1_form = {};
    tran_remark1_form.init = function () {
    }

    $("table[id^='tabrem']:checkbox").click(function () {

    });

    tran_remark1_form.CopyStr = function (tar) {
        var strRemark1 = "";
        $("#tran_remark1 :checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val() + "|";
            }
        });
        //其他文件輸入框
        $("#tran_remark1 :text").each(function (index) {
            var $this = $(this);
            if ($this.val() != "") {
                strRemark1 += "Z9-" + $this.val() + "-Z9|";
            }
        });
        tar.value = strRemark1;
    }
</script>
