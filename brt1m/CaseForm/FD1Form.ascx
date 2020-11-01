<%@ Control Language="C#" ClassName="FD1form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A5分割案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ttg1_agt_no = "", tfg1_div_arcase = "";
    protected string code_type = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        code_type = (Request["code_type"] ?? "").Trim();
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //代理人
            ttg1_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
            //分割後申請案性
            SQL = "SELECT  rs_code,prt_code,rs_detail,remark ";
            SQL += "FROM code_br WHERE rs_class like 'A1%' And  cr= 'Y' and dept='T' And rs_type='" + code_type + "' AND no_code='N' ";
            SQL += "and getdate() >= beg_date and end_date is null ORDER BY rs_code";
            tfg1_div_arcase = Util.Option(conn, SQL, "{rs_code}", "{rs_code}--{rs_detail}");
        }
    }
</script>

<div id="div_Form_FD1">
<%=Sys.GetAscxPath(this)%>
<TABLE border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
	<tr>
		<td class="lightbluetable" valign="top" ><strong>※、代理人(代碼)</strong></td>
		<td class="whitetablebg" colspan="7" >
		    <select id="ttg1_agt_no" NAME="ttg1_agt_no"><%#ttg1_agt_no%></select>
            <input type="hidden" name="tfzd_agt_no" id="tfzd_agt_no">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d1apply_no)">
            <strong>壹、<u>原註冊申請案號、商標/標章名稱、商標種類、分割件數、商標/標章圖樣</u></strong>
        </td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >一、原申請案號：</td>
		<td class=whitetablebg colspan="7">
			<input type=text id=fr1_apply_no name=fr1_apply_no class="onoff" onchange="reg.tfzd_apply_no.value=this.value">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >二、商標／標章名稱：</td>
		<td class=whitetablebg colspan="7">
			<input type=text id=fr1_appl_name name=fr1_appl_name class="onoff" onchange="reg.tfzd_appl_name.value=this.value">
		</TD>
	</tr>
    <tr>
		<td class=lightbluetable align=right >三、商標種類：</td>
		<td class=whitetablebg colspan="7">
            <input type="radio" name="fr1_S_Mark" class="onoff" value="" onclick="dmt_form.change_mark(1, this)">商標
            <span id="fr1_smark1" style="display:none">
                <input type="radio" name="fr1_S_Mark" class="onoff" value="S" onclick="dmt_form.change_mark(1, this)">92年修正前服務標章
            </span>
            <input type="radio" name="fr1_S_Mark" class="onoff" value="N" onclick="dmt_form.change_mark(1, this)">團體商標
            <span id="fr1_smark2" style="display:none">
                <input type="radio" name="fr1_S_Mark" class="onoff" value="M" onclick="dmt_form.change_mark(1, this)">團體標章
            </span>
            <input type="radio" name="fr1_S_Mark" class="onoff" value="L" onclick="dmt_form.change_mark(1, this)">證明標章
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >四、分割件數：</td>
		<td class=whitetablebg colspan="7">
			分割為<input type=text id=tot_num1 name=tot_num1 size="2" maxlength="2" onchange="br_form.Add_arcaseFD1(this.value)">件
			<input type=hidden id=cnt1 name=cnt1 value="0"><!--畫面上有幾筆-->
			<input type=text id=nfy_tot_num name=nfy_tot_num value="0">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >分割後申請案性：</td>
		<td class=whitetablebg colspan="7">
            <select id="tfg1_div_arcase" name="tfg1_div_arcase"><%#tfg1_div_arcase%></SELECT>
            <font color="red">(為列印商標註冊申請書，請選擇分割後申請案性)</font><input type=hidden name=tfy_div_arcase id=tfy_div_arcase>
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan=8 valign="top" STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d1Class)">
            <strong>肆、<u>分割商品/服務類別、名稱、證明內容及標的(請依序填寫商品/服務類別、名稱)</u></strong>
		</td>
	</tr>
	<tr class='sfont9'>
	    <td colspan=8 id="tdbr_da">
		</td>
	</tr>
    <script type="text/html" id="br_da_template"><!--分割樣板-->
		<TABLE id=tabbDa_$$ border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
        <thead>
		    <tr>
			    <td class="lightbluetable" align="right" width="30%" ><font color=red>分割(<span class="numberCh$$"></span>)</font>類別種類:</td>
			    <td class="whitetablebg" width="70%">
				    <INPUT type="radio" id=FD1_class_type_$$I name=FD1_class_type_$$ value="int">國際分類
				    <INPUT type="radio" id=FD1_class_type_$$O name=FD1_class_type_$$ value="old">舊類
			    </td>
		    </tr>
		    <tr>
			    <td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別" width="30%" ><font color=red>分割(<span class="numberCh$$"></span>)</font>類別項目:</td>		
			    <td class="whitetablebg" width="70%">共<INPUT type="text" id=FD1_class_count_$$ name=FD1_class_count_$$ size=2 maxlength=2 onchange="br_form.Add_classFD1('$$',this.value)">類
			        <input type=hidden name=FD1_count_$$ id=FD1_count_$$ value="0">
				    <input type=hidden name=FD1_ctrlcnt_$$ id=FD1_ctrlcnt_$$ value="0">
				    <input type=hidden name=FD1_cnt_$$ id=FD1_cnt_$$ value="0"><!--目前畫面上有幾筆-->
				    <input type=text name=FD1_case_sqlno_$$ id=FD1_case_sqlno_$$ value="">
				    <input type="text" name=FD1_class_$$ id=FD1_class_$$ readonly>
			    </td>
		    </tr>
		    <tr>
			    <td class="lightbluetable" align="right" style="cursor:pointer" ><font color=red>(<span class="numberCh$$"></span>)</font>名稱種類:</td>
			    <td class="whitetablebg">
                    <INPUT type="radio" id=FD1_Marka_$$T name=FD1_Marka_$$ value="T">商品/服務名稱
                    <INPUT type="radio" id=FD1_Marka_$$L name=FD1_Marka_$$ value="L">證明標的及內容
			    </td>
		    </tr>
        </thead>
        <tbody></tbody>
		</table>
    </script>
    <script type="text/html" id="br_class_templateFD1"><!--分割_類別樣板-->
        <tr class="tr_br_class_$$_##">
			<td class="lightbluetable" align="right" style="cursor:pointer" title="請輸入類別"><font color=red>(<span class="numberCh$$"></span>)</font>類別##:</td>
			<td class="whitetablebg">第<INPUT type="text" id=classa_$$_## name=classa_$$_## size=3 maxlength=3 onchange="br_form.count_kindFD1('$$','##')">類
			</td>
		</tr>
        <tr class="tr_br_class_$$_##">
			<td class="lightbluetable" align="right"><font color=red>(<span class="numberCh$$"></span>)</font>商品/服務名稱##:</td>
			<td class="whitetablebg"><textarea id="FD1_good_namea_$$_##" NAME="FD1_good_namea_$$_##" ROWS="10" COLS="55" onchange="br_form.good_name_count('FD1_good_namea_$$_##','FD1_good_counta_$$_##')"></textarea><br>
                共<input type="text" id=FD1_good_counta_$$_## name=FD1_good_counta_$$_## size=2>項
			</td>
		</tr>
    </script>

    <tr>
		<td class="lightbluetable" ROWSPAN=2 STYLE="cursor:pointer;COLOR:BLUE" ONCLICK="PMARK(d1Tran_remark)"><strong><u>備註：</u></strong></td>
		<td class=whitetablebg colspan=7>本案於<INPUT type=text id=O_item11 name=O_item11 size=10 class="dateField">(年/月/日)</td>
	</tr>
	<tr>		  
		<td class=whitetablebg colspan=7>
            另案辦理<INPUT type="radio" id=O_item12DO1 name=O_item12 value="DO1" onclick="reg.O_item13.value=''">異議案
			<INPUT type="radio" id=O_item12DI1 name=O_item12 value="DI1" onclick="reg.O_item13.value=''">評定案
			<INPUT type="radio" id=O_item12FT1 name=O_item12 value="FT1" onclick="reg.O_item13.value=''">移轉案
			<INPUT type="radio" id=O_item12FC1 name=O_item12 value="FC1" onclick="reg.O_item13.value=''">變更案
			<INPUT type="radio" id=O_item12FR1 name=O_item12 value="FR1" onclick="reg.O_item13.value=''">延展案
			<INPUT type="radio" id=O_item12ZZ name=O_item12 value="ZZ">其他<input type="text" id="O_item13" name="O_item13" size=20 onchange="reg.O_item12[5].checked=true">案
		</TD>
	</tr>
    <tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="COLOR:BLUE" onclick="PMARK(d1attech)">
            <strong><u>附件：</u></strong>
            <input type=text id="tfzd_remark1" name="tfzd_remark1" value="">
		</td>
	</tr>
    <tr class="br_attchstr_FD1">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" id="ttz1_Z1" NAME="ttz1_Z1" value="Z1"  onclick="br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">委任書(<input TYPE="checkbox" id="ttz1_Z1C" NAME="ttz1_Z1C" value="Z1C">附中文譯本)。)</td>
	</tr>
	<tr class="br_attchstr_FD1">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z2" id="ttz1_Z2" value="Z2" onclick="br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">按分割件數之分割申請書副本<input TYPE="text" NAME="ttz1_Z2C" id="ttz1_Z2C" value="" size="2" onchange="reg.ttz1_Z2.checked=true;br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)">份。</td>
	</tr>
	<tr class="br_attchstr_FD1">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z3" id="ttz1_Z3" value="Z3" onclick="br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">分割後之商標註冊申請書正本(含相關文件)<input TYPE="text" NAME="ttz1_Z3C" id="ttz1_Z3C" value="" size="2" onchange="reg.ttz1_Z3.checked=true;br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)">份。(每份應附商標圖樣5張)</td>
	</tr>
	<tr class="br_attchstr_FD1">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z4" id="ttz1_Z4" value="Z4" onclick="br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">全體共有人同意書。</td>
	</tr>
	<tr class="br_attchstr_FD1">
		<td class="lightbluetable" align="right"><input TYPE="checkbox" NAME="ttz1_Z9" id="ttz1_Z9" value="Z9" onclick="br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)"></td>
		<td class="whitetablebg" colspan="7">其他證明文件。<input TYPE="text" NAME="ttz1_Z9t" id="ttz1_Z9t" SIZE="50" onchange="br_form.AttachStr1('.br_attchstr_FD1','ttz1_',reg.tfzd_remark1)"></td>
	</tr>
</TABLE>
</div>


<script language="javascript" type="text/javascript">
    //分割件數
    br_form.Add_arcaseFD1 = function (arcaseCount) {
        if (!IsNumeric(arcaseCount)) {
            alert("分割件數請輸入數值!!");
            settab("#tran");
            $("#tot_num1").focus();
            return false;
        }
        if(arcaseCount>30){
            alert("分割案件數不可超過30筆");
            $("#tot_num1").val("1").focus();
            return false;

        }

        var doCount = Math.max(0, CInt(arcaseCount));//要改為幾筆,最少是0
        var cnt1 = CInt($("#cnt1").val());//目前畫面上有幾筆
        if (doCount > cnt1) {//要加
            for (var nRow = cnt1; nRow < doCount ; nRow++) {
                var copyStr = $("#br_da_template").text() || "";
                copyStr = copyStr.replace(/\$\$/g, nRow + 1);
                $("#tdbr_da").append(copyStr);
                $(".numberCh"+(nRow + 1)).html(NumberToCh(nRow+1));
                $("#cnt1").val(nRow + 1);
                br_form.Add_classFD1(nRow+1,1);//預設一個類別
            }
        } else {
            //要減
            for (var nRow = cnt1; nRow > doCount ; nRow--) {
                $('#tabbDa_' + nRow).remove();
                $("#cnt1").val(nRow - 1);
            }
        }
    }

    //*****共N類
    br_form.Add_classFD1 = function (nSplit, classCount) {
        if (!IsNumeric(classCount)) {
            alert("分割後類別項目"+nSplit+"：請輸入數值!!");
            settab("#tran");
            $("#FD1_class_count_"+nSplit).focus();
            return false;
        }

        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num2 = CInt($("#FD1_cnt_"+nSplit).val());//目前畫面上有幾筆
        if (doCount > num2) {//要加
            for (var nRow = num2; nRow < doCount ; nRow++) {
                var copyStr = $("#br_class_templateFD1").text() || "";
                copyStr = copyStr.replace(/\$\$/g, nSplit);
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $("#tabbDa_"+nSplit+" tbody").append(copyStr);
                $(".numberCh"+nSplit).html(NumberToCh(nSplit));
                $("#FD1_cnt_"+nSplit).val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num2; nRow > doCount ; nRow--) {
                $('.tr_br_class_'+nSplit+'_' + nRow).remove();
                $("#FD1_cnt_"+nSplit).val(nRow - 1);
            }
        }
    }

    /*
    //依商品名稱計算類別
    br_form.good_name_count = function (nSplit, nRow) {
        var MyString = $("#FD1_good_namea_"+nSplit+"_" + nRow).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        $("#FD1_good_counta_"+nSplit+"_" + nRow).val("");
        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#FD1_good_namea_"+nSplit+"_" + nRow).val(MyString);
            var aKind = myarray.length;//共幾類
            alert("商品內容共" + aKind + "項");
            $("#FD1_good_counta_"+nSplit+"_" + nRow).val(aKind);

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }*/

    //類別串接
    br_form.count_kindFD1 = function (nSplit,nRow) {
        var vobj=$("#classa_"+nSplit+"_" + nRow);//第xx類
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

        var nclass = $("#tabbDa_"+nSplit+">tbody input[id^='classa_"+nSplit+"_']").map(function (index) {
            if (index == 0 || $(this).val() != "") return $(this).val();
        });
        $("#FD1_class_"+nSplit).val(nclass.get().join(','));
        $("#FD1_class_count_"+nSplit).val(Math.max(CInt($("#FD1_class_count_"+nSplit).val()), nclass.length));//回寫共N類
    }


    //附件
    br_form.AttachStr1 = function (selector, pfld, tar) {
        var strRemark1 = "";
        $(selector + ":checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val()
                //查有無份數欄位
                if ($("#" + pfld + $this.val() + "C").length > 0) {
                    strRemark1 += ";" + $("#" + pfld + $this.val() + "C").val();
                }
                else if ($("#" + pfld + $this.val() + "t").length > 0) {
                    strRemark1 += ";" + $("#" + pfld + $this.val() + "t").val();
                }
                strRemark1 += "|";
            }
        });
        tar.value = strRemark1;
    }

    //原申請案號
    $("#fr1_apply_no").blur(function (e) {
        chk_dmt_applyno($(this)[0],9);
        $("#tfzd_apply_no").val($(this).val());
    })

    //交辦內容綁定
    br_form.bindFD1 = function () {
        console.log("fd1.br_form.bind");
        if (jMain.case_main.length == 0) {
        } else {
            //*出名代理人代碼
            $("#ttg1_agt_no").val(jMain.case_main[0].agt_no);
            $("#tfzd_agt_no").val(jMain.case_main[0].agt_no);

            $("#fr1_apply_no").val(jMain.case_main[0].apply_no);//原申請案號
            $("#fr1_appl_name").val(jMain.case_main[0].appl_name);//商標／標章名稱
            //商標種類
            $("input[name=fr1_S_Mark][value='" + jMain.case_main[0].S_mark + "']").prop("checked", true);
            //分割件數
            if (main.prgid == "brt52") {
                $("#tot_num1").lock();
            }
            $("#tot_num1,#nfy_tot_num").val(jMain.case_main[0].tot_num);
            br_form.Add_arcaseFD1(jMain.case_main[0].tot_num);
            $.each(jMain.case_sql, function (i, item) {
                var spl_num = (i + 1);
                if (main.prgid == "brt52") {
                    $("#FD1_seqa_" + spl_num).val(item.seq);
                    $("#FD1_seq1a_" + spl_num).val(item.seq1);
                }
                $("#FD1_case_sqlno_" + spl_num).val(item.case_sqlno);//流水號
                $("#FD1_class_count_" + spl_num).val(item.class_count);//共N類
                $("#FD1_class_" + spl_num).val(item.class);//類別
                //類別種類
                $("input[name='FD1_class_type_" + spl_num + "'][value='" + item.class_type + "']").prop('checked', true);
                //名稱種類
                $("input[name='FD1_Marka_" + spl_num + "'][value='" + item.mark + "']").prop('checked', true);
                //產生分割_類別
                br_form.Add_classFD1(spl_num, item.class_count);
                $.each(jMain.case_good, function (i, item) {
                    var good_num = (i + 1);
                    if (item.case_sqlno == $("#FD1_case_sqlno_" + spl_num).val()) {
                        $("#classa_" + spl_num + "_" + good_num).val(item.class);//第X類
                        $("#FD1_good_counta_" + good_num).val(item.dmt_goodcount);//共N項
                        $("#FD1_good_namea_" + good_num).val(item.dmt_goodname);//商品名稱
                    }
                });
                br_form.count_kindFD1(spl_num,1);////類別串接
            });
            //分割後申請案性
            $("#tfg1_div_arcase").val(jMain.case_main[0].div_arcase);
            //**備註
            if (jMain.case_tran.length > 0) {
                if (jMain.case_tran[0].other_item.indexOf(";") > -1) {
                    var oitem = jMain.case_tran[0].other_item.split(";");
                    $("#O_item11").val(oitem[0]);
                    $("input[name='O_item12'][value='" + oitem[1] + "']").prop('checked', true);
                    $("#O_item13").val(oitem[2]);
                }
            }
            //**附件
            $("#tfzd_remark1").val(jMain.case_main[0].remark1);
            if (jMain.case_main[0].remark1 != "") {
                var arr_remark1 = jMain.case_main[0].remark1.split("|");
                for (var i = 0; i < arr_remark1.length; i++) {
                    //var str="Z2;2|Z3;3|Z4|Z9;333xxxxx|";
                    var Rem_detail = arr_remark1[i].split(";");
                    $("#ttz1_" + Rem_detail[0]).prop("checked", true);
                    $("#ttz1_" + Rem_detail[0] + "C").val(Rem_detail[1]);//副本數
                    $("#ttz1_" + Rem_detail[0] + "t").val(Rem_detail[1]);//其他證明文件說明
                }
            }
            //主檔商標種類控制
            $("#smark,#fr_smark2").hide();
            $("#fr_smark1,#fr_smark3").show();
            if (main.prgid != "brt52") {
                $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
            }
        }
    }
</script>
