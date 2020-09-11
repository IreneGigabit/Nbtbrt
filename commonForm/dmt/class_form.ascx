<%@ Control Language="C#" ClassName="class_form" %>
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
		<TABLE id=tabbr1 style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
            <thead>
		        <tr>
			        <td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(p1Good)"><strong>陸、<u>指定使用商品類別及名稱</u></strong></td>
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
			        <td class="whitetablebg" colspan="7" >共<input type="text" id=tfz1_class_count name=tfz1_class_count size=2 onchange="class_form.Add_button(this.value)">類
				        <input type=text id=num1 name=num1 value="0"><!--畫面上有幾筆-->
				        <input type=hidden id=ctrlnum1 name=ctrlnum1 value="0">
				        <input type=hidden id=ctrlcount1 name=ctrlcount1 value="0">
				        <input type="text" name=tfz1_class id=tfz1_class style="width:70%" readonly>
			        </td>
		        </tr>
            </thead>
            <tbody></tbody>
            <script type="text/html" id="class_template"><!--類別樣板-->
		        <tr class="tr_class_##">
			        <td class="lightbluetable" align="right" style="cursor:pointer" >類別##：</td>
			        <td class="whitetablebg" colspan="7">第<INPUT type="text" id=class1_## name=class1_## size=3 maxlength=3 onchange="class_form.count_kind('##')">類</td>		
		        </tr>
		        <tr class="tr_class_##" style="height:107.6pt">
			        <td class="lightbluetable" align="right" width="18%">商品名稱##：</td>
			        <td class="whitetablebg" colspan="7">
                        <textarea id="good_name11" NAME="good_name1_##" ROWS="10" COLS="75" onchange="call good_name_count('good_name1_##','good_count1_##')"></textarea>
                        <br>共<input type="text" name=good_count1_## size=2>項</td>
		        </tr>
		        <tr class="tr_class_##">
			        <td class="lightbluetable" align="right">商品群組代碼##：</td>
			        <td class="whitetablebg" colspan="7"><textarea id=grp_code1_## NAME=grp_code11 ROWS="1" COLS="50"></textarea>(跨群組請以全形「、」作分隔)</td>
		        </tr>
            </script>
		</table>
	</td>	
</tr>

<script language="javascript" type="text/javascript">
    var class_form = {};

    //共N類
    class_form.Add_button = function (classCount) {
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
                console.log(nRow);
                $('.tr_class_' + nRow).remove();
                $("#num1").val(nRow - 1);
            }
        }
    }

    //類別串接
    class_form.count_kind = function (nRow) {
        if ($("#class1_" + nRow).val() != "") {
            if (isNumeric($("#class1_" + nRow).val())) {
                $("#class1_" + nRow).val(("000" + $("#class1_" + nRow).val()).Right(3));//補0
            } else {
                alert("商品類別請輸入數值!!!");
                $("#class1_" + nRow).val("");
            }
        }

        $("#tfz1_class").val($("#tabbr1>tbody input[id^='class1_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        }).get().join(','));
    }
</script>
