<%@ Control Language="C#" ClassName="FD2form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A5分割案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg2_agt_no = "", tfg2_div_arcase = "";
    protected string code_type = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        code_type = (Request["code_type"] ?? "").Trim();
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //代理人
            ttg2_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
            //分割後申請案性
            SQL = "SELECT  rs_code,prt_code,rs_detail,remark ";
            SQL += "FROM code_br WHERE rs_class like 'A1%' And  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' ";
            SQL += "and getdate() >= beg_date and end_date is null ORDER BY rs_code";
            tfg2_div_arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}---{rs_detail}");
        }
    }
</script>

<div id="div_Form_FD2">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="ttg2_agt_no" NAME="ttg2_agt_no"><%#ttg2_agt_no%></select>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d2Issue_no)">
            <strong>壹、<u>原註冊申請案號、商標/標章名稱、商標種類、分割件數、商標/標章圖樣</u></strong>
        </td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >一、原註冊案號：</td>
		<td class=whitetablebg colspan="7">
			<input type=text id=fr2_issue_no name=fr2_issue_no class="onoff" onchange="reg.tfzd_issue_no.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >二、商標／標章名稱：</td>
		<td class=whitetablebg colspan="7">
			<input type=text id=fr2_appl_name name=fr2_appl_name class="onoff" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
    <tr>
		<td class=lightbluetable align=right >三、商標種類：</td>
		<td class=whitetablebg colspan="7">
            <input type="radio" name="fr2_S_Mark" class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
            <input type="radio" name="fr2_S_Mark" class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
            <input type="radio" name="fr2_S_Mark" class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
            <span id="fr2_smark" style="display:none">
                <input type="radio" name="fr2_S_Mark" class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
            </span>
            <input type="radio" name="fr2_S_Mark" class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >四、分割件數：</td>
		<td class=whitetablebg colspan="7">
			分割為<input type=text id=tot_num2 name=tot_num2 size="2" maxlength="2" onchange="br_form.Add_arcaseFD2(this.value)">件
			<input type=hidden id=cnt2 name=cnt2 value="0"><!--畫面上有幾筆-->
			<input type=hidden id=count2 name=count2 value="0">
			<input type=hidden id=ctrlcnt2 name=ctrlcnt2 value="">
		</TD>
	</tr>
	<tr style="display:none">
		<td class=lightbluetable align=right >分割後申請案性：</td>
		<td class=whitetablebg colspan="7">
            <select id="tfg2_div_arcase" name="tfg2_div_arcase"><%#tfg2_div_arcase%></SELECT>
            <font color="red">(為列印商標註冊申請書，請選擇分割後申請案性)</font>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d2Class)">
            <strong>肆、<u>分割商品/服務類別、名稱、證明內容及標的(請依序填寫商品/服務類別、名稱)</u></strong>
        </td>
	</tr>
	<tr class='sfont9'>
	    <td colspan=8 id="tdbr_db">
		</td>
	</tr>
    <script type="text/html" id="br_db_template"><!--分割樣板-->
		<TABLE id=tabbDb_$$ border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
        <thead>
		    <tr>
			    <td class="lightbluetable" align="right" width="30%" ><font color=red>分割(<span class="numberCh$$"></span>)</font>類別種類:</td>
			    <td class="whitetablebg" width="70%">
				    <INPUT type="radio" id=FD2_class_type_$$I name=FD2_class_type_$$ value="int">國際分類
				    <INPUT type="radio" id=FD2_class_type_$$O name=FD2_class_type_$$ value="old">舊類
			    </td>
		    </tr>
		    <tr>
			    <td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別" width="30%" ><font color=red>分割(<span class="numberCh$$"></span>)</font>類別項目:</td>		
			    <td class="whitetablebg" width="70%">共<INPUT type="text" id=FD2_class_count_$$ name=FD2_class_count_$$ size=2 maxlength=2 onchange="br_form.Add_class_FD2('$$',this.value)">類
			        <input type=hidden name=FD2_count_$$ id=FD2_count_$$ value="0">
				    <input type=hidden name=FD2_ctrlcnt_$$ id=FD2_ctrlcnt_$$ value="0">
				    <input type=hidden name=FD2_cnt_$$ id=FD2_cnt_$$ value="0"><!--目前畫面上有幾筆-->
				    <input type=text name=FD2_case_sqlno_$$ id=FD2_case_sqlno_$$ value="">
				    <input type="text" name=FD2_class_$$ id=FD2_class_$$ readonly>
			    </td>
		    </tr>
		    <tr>
			    <td class="lightbluetable" align="right" style="cursor:pointer" ><font color=red>(<span class="numberCh$$"></span>)</font>名稱種類:</td>
			    <td class="whitetablebg">
                    <INPUT type="radio" id=FD2_Markb_$$T name=FD2_Markb_$$ value="T">商品/服務名稱
                    <INPUT type="radio" id=FD2_Markb_$$L name=FD2_Markb_$$ value="L">證明標的及內容
			    </td>
		    </tr>
        </thead>
        <tbody></tbody>
		</table>
    </script>
    <script type="text/html" id="br_class_templateFD2"><!--分割_類別樣板-->
        <tr class="tr_br_class_$$_##">
			<td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別"><font color=red>(<span class="numberCh$$"></span>)</font>類別##:</td>
			<td class="whitetablebg">第<INPUT type="text" id=classb_$$_## name=classb_$$_## size=3 maxlength=3 onchange="br_form.count_kindFD2('$$','##')">類
			</td>
		</tr>
        <tr class="tr_br_class_$$_##">
			<td class="lightbluetable" align="right"><font color=red>(<span class="numberCh$$"></span>)</font>商品/服務名稱##:</td>
			<td class="whitetablebg"><textarea id="FD2_good_nameb_$$_##" NAME="FD2_good_nameb_$$_##" ROWS="10" COLS="55" onchange="br_form.good_name_count('FD2_good_nameb_$$_##','FD2_good_countb_$$_##')"></textarea><br>
                共<input type="text" id=FD2_good_countb_$$_## name=FD2_good_countb_$$_## size=2>項
			</td>
		</tr>
    </script>
    <tr>
        <td class="lightbluetable" ROWSPAN=2 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d2Tran_remark)"><strong><u>備註：</u></strong></td>
		<td class=whitetablebg colspan=7>本案於<INPUT type=text id=O_item21 name=O_item21 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr>		  
		<td class=whitetablebg colspan=7>
            另案辦理<INPUT type="radio" id=O_item22DO1 name=O_item22 value="DO1" onclick="reg.O_item23.value=''">異議案
			<INPUT type="radio" id=O_item22DI1 name=O_item22 value="DI1" onclick="reg.O_item23.value=''">評定案
			<INPUT type="radio" id=O_item22FT1 name=O_item22 value="FT1" onclick="reg.O_item23.value=''">移轉案
			<INPUT type="radio" id=O_item22FC1 name=O_item22 value="FC1" onclick="reg.O_item23.value=''">變更案
			<INPUT type="radio" id=O_item22FR1 name=O_item22 value="FR1" onclick="reg.O_item23.value=''">延展案
			<INPUT type="radio" id=O_item22ZZ name=O_item22 value="ZZ">其他<input type="text" id="O_item23" name="O_item23" size=20 onchange="reg.O_item22[5].checked=true">案
		</TD>
	</tr>	
    <tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(d2Attech)">
            <strong><u>附件：</u></strong>
        </td>
	</tr>
    <tr class="br_attchstrFD2">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz2_Z1" NAME="ttz2_Z1" value="Z1"  onclick="br_form.AttachStr1('.br_attchstrFD2', 'ttz2_', reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz2_Z1C" NAME="ttz2_Z1C" value="Z1C">附中文譯本)。)</td>
	</tr>
	<tr class="br_attchstrFD2">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz2_Z2" id="ttz2_Z2" value="Z2" onclick="br_form.AttachStr1('.br_attchstrFD2', 'ttz2_', reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">按分割件數之分割申請書副本<input TYPE="text" NAME="ttz2_Z2C" value="" size="2" onchange="reg.ttz2_Z2.checked=true;br_form.AttachStr1('.br_attchstrFD2','ttz2_',reg.tfzd_remark1)">份。(每份應附商標圖樣5張)</td>
	</tr>
	<tr class="br_attchstrFD2">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz2_Z4" id="ttz2_Z4" value="Z4" onclick="br_form.AttachStr1('.br_attchstrFD2', 'ttz2_', reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
	</tr>
</TABLE>
</div>

<script language="javascript" type="text/javascript">
    //分割件數
    br_form.Add_arcaseFD2 = function (arcaseCount) {
        if (!IsNumeric(arcaseCount)) {
            alert("分割件數請輸入數值!!");
            settab("#tran");
            $("#tot_num2").focus();
            return false;
        }
        if(arcaseCount>30){
            alert("分割案件數不可超過30筆");
            $("#tot_num2").val("1").focus();
            return false;

        }

        var doCount = Math.max(0, CInt(arcaseCount));//要改為幾筆,最少是0
        var cnt2 = CInt($("#cnt2").val());//目前畫面上有幾筆
        if (doCount > cnt2) {//要加
            for (var nRow = cnt2; nRow < doCount ; nRow++) {
                var copyStr = $("#br_db_template").text() || "";
                copyStr = copyStr.replace(/\$\$/g, nRow + 1);
                $("#tdbr_db").append(copyStr);
                $(".numberCh"+(nRow + 1)).html(NumberToCh(nRow+1));
                $("#cnt2").val(nRow + 1);
                br_form.Add_class_FD2(nRow+1,1);//預設一個類別
            }
        } else {
            //要減
            for (var nRow = cnt2; nRow > doCount ; nRow--) {
                $('#tabbDb_' + nRow).remove();
                $("#cnt2").val(nRow - 1);
            }
        }
    }

    //*****共N類
    br_form.Add_class_FD2 = function (nSplit, classCount) {
        if (!IsNumeric(classCount)) {
            alert("分割後類別項目"+nSplit+"：請輸入數值!!");
            settab("#tran");
            $("#FD2_class_count_"+nSplit).focus();
            return false;
        }

        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num2 = CInt($("#FD2_cnt_"+nSplit).val());//目前畫面上有幾筆
        if (doCount > num2) {//要加
            for (var nRow = num2; nRow < doCount ; nRow++) {
                var copyStr = $("#br_class_templateFD2").text() || "";
                copyStr = copyStr.replace(/\$\$/g, nSplit);
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbDb_" + nSplit + " tbody").append(copyStr);
                $(".numberCh"+nSplit).html(NumberToCh(nSplit));
                $("#FD2_cnt_"+nSplit).val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num2; nRow > doCount ; nRow--) {
                $('.tr_br_class_'+nSplit+'_' + nRow).remove();
                $("#FD2_cnt_"+nSplit).val(nRow - 1);
            }
        }
    }

    /*
    //依商品名稱計算類別
    br_form.good_name_count = function (nSplit, nRow) {
        var MyString = $("#FD2_good_nameb_"+nSplit+"_" + nRow).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        $("#FD2_good_countb_"+nSplit+"_" + nRow).val("");
        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#FD2_good_nameb_"+nSplit+"_" + nRow).val(MyString);
            var aKind = myarray.length;//共幾類
            alert("商品內容共" + aKind + "項");
            $("#FD2_good_countb_"+nSplit+"_" + nRow).val(aKind);

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }*/

    //類別串接
    br_form.count_kindFD2 = function (nSplit,nRow) {
        var vobj = $("#classb_" + nSplit + "_" + nRow);//第xx類
        if (vobj.val() != "") {
            if (IsNumeric(vobj.val())) {
                var x = ("000" + vobj.val()).Right(3);//補0
                vobj.val(x);
                br_form.checkclass(x);
            } else {
                alert("商品類別請輸入數值!!!");
                vobj.val("");
            }
        }

        var nclass = $("#tabbDb_" + nSplit + ">tbody input[id^='classb_" + nSplit + "_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        }); 
        $("#FD2_class_"+nSplit).val(nclass.get().join(','));
        $("#FD2_class_count_"+nSplit).val(Math.max(CInt($("#FD2_class_count_"+nSplit).val()), nclass.length));//回寫共N類
    }

    //原註冊案號
    $("#fr2_issue_no").blur(function (e) {
        chk_dmt_issueno($(this)[0],8);
        $("#tfzd_issue_no").val($(this).val());
    })

    //交辦內容綁定
    br_form.bindFD2 = function () {
        console.log("fd2.br_form.bind");
        if (jMain.case_main.length == 0) {
            br_form.Add_arcaseFD2(1);//分割預設顯示第1筆
        } else {
            //*出名代理人代碼
            $("#ttg2_agt_no").val(jMain.case_main[0].agt_no);

            $("#fr2_issue_no").val(jMain.case_main[0].issue_no);//原註冊案號
            $("#fr2_appl_name").val(jMain.case_main[0].appl_name);//商標／標章名稱
            //商標種類
            $("input[name=fr2_S_Mark][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
            //分割件數
            if (main.prgid == "brt52") {
                $("#tot_num2").lock();
            }
            $("#tot_num2,#nfy_tot_num").val(jMain.case_main[0].tot_num).triggerHandlder("change");
            $.each(jMain.case_sql, function (i, item) {
                var spl_num = (i + 1);
                if (main.prgid == "brt52") {
                    $("#FD2_seqb_" + spl_num).val(item.seq);
                    $("#FD2_seq1b_" + spl_num).val(item.seq1);
                }
                $("#FD2_case_sqlno_" + spl_num).val(item.case_sqlno);//流水號
                $("#FD2_class_count_" + spl_num).val(item.class_count);//共N類
                $("#FD2_class_" + spl_num).val(item.class);//類別
                //類別種類
                $("input[name='FD2_class_type_" + spl_num + "'][value='" + item.class_type + "']").prop('checked', true);
                //名稱種類
                $("input[name='FD2_Markb_" + spl_num + "'][value='" + item.mark + "']").prop('checked', true);
                //產生分割_類別
                br_form.Add_classFD2(spl_num, item.class_count);
                $.each(jMain.case_good, function (i, item) {
                    var good_num = (i + 1);
                    if (item.case_sqlno == $("#FD2_case_sqlno_" + spl_num).val()) {
                        $("#classb_" + spl_num + "_" + good_num).val(item.class);//第X類
                        $("#FD2_good_countb_" + good_num).val(item.dmt_goodcount);//共N項
                        $("#FD2_good_nameb_" + good_num).val(item.dmt_goodname);//商品名稱
                    }
                });
                br_form.count_kindFD2(spl_num, 1);////類別串接
            });
            //分割後申請案性
            $("#tfg2_div_arcase").val(jMain.case_main[0].div_arcase);
            //**備註
            if (jMain.case_tran.length > 0) {
                if (jMain.case_tran[0].other_item.indexOf(";") > -1) {
                    var oitem = jMain.case_tran[0].other_item.split(";");
                    $("#O_item21").val(oitem[0]);
                    $("input[name='O_item22'][value='" + oitem[1] + "']").prop('checked', true);
                    $("#O_item23").val(oitem[2]);
                }
            }
            //**附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z2;2|Z3;3|Z4|Z9;333xxxxx|";
                    var Rem_detail = arr_remark1[i].split(";");
                    $("#ttz2_" + Rem_detail[0]).prop("checked", true);
                    $("#ttz2_" + Rem_detail[0] + "C").val(Rem_detail[1]);//副本數
                    $("#ttz2_" + Rem_detail[0] + "t").val(Rem_detail[1]);//其他證明文件說明
                }
            }
            //主檔商標種類控制
            $("#fr_smark2").hide();
            $("#smark,#fr_smark1,#fr_smark3").show();
            if (main.prgid != "brt52") {
                $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
            }
        }
    }
</script>
