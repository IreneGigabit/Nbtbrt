<%@ Control Language="C#" ClassName="FA1Form_remark1" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
</script>

<%=Sys.GetAscxPath(this)%>
<!--附件様版1-->
<script type="text/html" id="tabbr_remark1_1">
	<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="sfont9" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="sfont9" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="sfont9" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="sfont9" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="sfont9" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_5">
  <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
    <tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z8C" NAME="tt11_Z8C" value="Z8C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_D">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z6C" NAME="tt11_Z6C" value="Z6C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z8C" NAME="tt11_Z8C" value="Z8C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_9">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z6C" NAME="tt11_Z6C" value="Z6C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
		</tr>
		<tr>
			<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
			<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
		</tr>
	</table>
</script>
<!--附件様版2-->
<script type="text/html" id="tabbr_remark1_2">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_6">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z8C" NAME="tt11_Z8C" value="Z8C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_A">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z61" NAME="tt11_Z61" value="Z61" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z61C" NAME="tt11_Z61C" value="Z61C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_E">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z6C" NAME="tt11_Z6C" value="Z6C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z81" value="Z81" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z81C" NAME="tt11_Z81C" value="Z81C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>
<!--附件様版3-->
<script type="text/html" id="tabbr_remark1_3">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。（商標圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">載有本件聲音之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_7">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。（商標圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">載有本件聲音之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z8C" NAME="tt11_Z8C" value="Z8C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_B">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。（標章圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">載有本件聲音標章之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z61" NAME="tt11_Z61" value="Z61" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z61C" NAME="tt11_Z61C" value="Z61C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_F">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">標章圖樣浮貼一式5張。（標章圖樣非以五線譜、簡譜表示者，免貼圖）</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z10" NAME="tt11_Z10" value="Z10" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">載有本件聲音標章之.wav檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr >
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z6C" NAME="tt11_Z6C" value="Z6C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z81" value="Z81" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z81C" NAME="tt11_Z81C" value="Z81C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>
<!--附件様版4-->
<script type="text/html" id="tabbr_remark1_4">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr style="display:none">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">大陸地區之自然人或法人之身分證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">不具功能性之證據資料。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_8">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地團體商標者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z8C" NAME="tt11_Z8C" value="Z8C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">不具功能性之證據資料。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_C">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人資格證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z61" NAME="tt11_Z61" value="Z61" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z61C" NAME="tt11_Z61C" value="Z61C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_G">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z3" NAME="tt11_Z3" value="Z3" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">法人、團體或政府機關證明文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人得為證明之資格或能力之文件。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z51" NAME="tt11_Z51" value="Z51" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人具代表性證明文件(申請產地證明標章者始需檢附)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z5C" NAME="tt11_Z5C" value="Z5C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z6" NAME="tt11_Z6" value="Z6" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書(<input TYPE="checkbox" id="tt11_Z6C" NAME="tt11_Z6C" value="Z6C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="tt11_Z81" value="Z81" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">使用規範書之電子檔光碟片(<input TYPE="checkbox" id="tt11_Z81C" NAME="tt11_Z81C" value="Z81C" onclick="br_form.AttachStr()"/>附中文譯本或應記載事項之中文節譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z7" NAME="tt11_Z7" value="Z7" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">申請人不從事所證明商品之製造、行銷或服務提供之聲明。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z8" NAME="tt11_Z8" value="Z8" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
			
	</tr>
	</table>
</script>
		
<script type="text/html" id="tabbr_remark1_I">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">個別視圖各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z21" NAME="tt11_Z21" value="Z21" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標樣本。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_J">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">個別圖像各浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z21" NAME="tt11_Z21" value="Z21" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">存載動態商標之AVI或MPEG檔光碟片。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

<script type="text/html" id="tabbr_remark1_K">
  <table border="0" class="bluetable"  cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z1" NAME="tt11_Z1" value="Z1" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標圖樣浮貼一式5張。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z21" NAME="tt11_Z21" value="Z21" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">商標樣本。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z2" NAME="tt11_Z2" value="Z2" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">優先權證明文件(<input TYPE="checkbox" id="tt11_Z2C" NAME="tt11_Z2C" value="Z2C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
		
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z31" NAME="tt11_Z31" value="Z31" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">展覽會優先權證明文件(<input TYPE="checkbox" id="tt11_Z31C" NAME="tt11_Z31C" value="Z31C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z4" NAME="tt11_Z4" value="Z4" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="tt11_Z4C" NAME="tt11_Z4C" value="Z4C" onclick="br_form.AttachStr()"/>附中文譯本)。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z5" NAME="tt11_Z5" value="Z5" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">已取得識別性之具體事證。</td>
	</tr>
	<tr>
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="tt11_Z9" NAME="tt11_Z9" value="Z9" onclick="br_form.AttachStr()"/></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" id="tt11_Z9t" NAME="tt11_Z9t" SIZE="50" onchange="br_form.AttachStr()"/></td>
	</tr>
	</table>
</script>

