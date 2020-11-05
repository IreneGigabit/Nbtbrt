//存檔檢查
main.savechk = function () {
    //2014/4/22增加檢查是否為雙邊代理查照對象,客戶名稱
    if (cust_name_chk($("#F_ap_cname1").val() + $("#F_ap_cname2").val(), $("#F_ap_ename1").val() + $("#F_ap_ename2").val())) {
        settab("#cust");
        return false;
    }

    //2014/4/22增加檢查是否為雙邊代理查照對象,客戶代表人名稱
    if (aprep_name_chk($("#F_ap_crep").val(), $("#F_ap_erep").val())) {
        settab("#cust");
        return false;
    }

    //聯絡人檢查
    if (IsEmpty($("#tfy_att_sql").val())) {
        alert("聯絡人資料不得為空白！");
        settab("#attent");
        $("#tfy_att_sql").focus();
        return false;
    }

    //申請人檢查
    if ($("#apnum").val() == "0") {
        alert("請輸入申請人資料！");
        settab("#apcust");
        $("#AP_Add_button").focus();
        return false;
    }
    for (var tapnum = 1; tapnum <= CInt($("#apnum").val()) ; tapnum++) {
        if (IsEmpty($("#apcust_no_" + tapnum).val())) {
            alert("申請人編號不得為空白！");
            settab("#apcust");
            $("#apcust_no_" + tapnum).focus();
            return false;
        }
        $("#ap_cname_" + tapnum).val($("#ap_cname1_" + tapnum).val() + $("#ap_cname2_" + tapnum).val());
        $("#ap_ename_" + tapnum).val($("#ap_ename1_" + tapnum).val() + " " + $("#ap_ename2_" + tapnum).val());
        if ($("#ap_cname1_" + tapnum).val() != "") {
            if (fDataLen($("#ap_cname1_" + tapnum))) {
                settab("#apcust");
                $("#ap_cname1_" + tapnum).focus();
                return false;
            }
        }
        if ($("#ap_cname2_" + tapnum).val() != "") {
            if (fDataLen($("#ap_cname2_" + tapnum))) {
                settab("#apcust");
                $("#ap_cname2_" + tapnum).focus();
                return false;
            }
        }
        if ($("#ap_ename1_" + tapnum).val() != "") {
            if (fDataLen($("#ap_ename1_" + tapnum))) {
                settab("#apcust");
                $("#ap_ename1_" + tapnum).focus();
                return false;
            }
        }
        if ($("#ap_ename2_" + tapnum).val() != "") {
            if (fDataLen($("#ap_ename2_" + tapnum))) {
                settab("#apcust");
                $("#ap_ename2_" + tapnum).focus();
                return false;
            }
        }
        //2014/4/22增加檢查是否為雙邊代理查照對象
        if (cust_name_chk($("#ap_cname_" + tapnum).val(), $("#ap_ename_" + tapnum).val())) {
            settab("#apcust");
            return false;
        }
        if (aprep_name_chk($("#ap_crep_" + tapnum).val(), $("#ap_erep_" + tapnum).val())) {
            settab("#apcust");
            return false;
        }
    }
    //收費與接洽事項檢查
    if (IsEmpty($("#tfy_Arcase").val())) {
        alert("客收/請款案性不得為空白！");
        settab("#case");
        $("#tfy_Arcase").focus();
        return false;
    }
    //次委辦案性與金額檢查
    for (var q = 1; q <= CInt($("#TaCount").val()) ; q++) {
        //檢查沒選案性但有輸金額
        if (IsEmpty($("#nfyi_item_Arcase_" + q).val())) {
            if (CInt($("#nfyi_Service_" + q).val()) != 0) {
                alert(q + ".其他費用服務費不為0，請輸入" + q + ".其他費用之案性！");
                settab("#case");
                $("#nfyi_item_Arcase_" + q).focus();
                return false;
            }

            if (CInt($("#nfyi_fees_" + q).val()) != 0) {
                alert(q + ".其他費用規費不為0，請輸入" + q + ".其他費用之案性！");
                settab("#case");
                $("#nfyi_item_Arcase_" + q).focus();
                return false;
            }
        }
    }

    if (IsEmpty($("#tfy_Ar_mark").val())) {
        alert("請款註記不得為空白！");
        settab("#case");
        $("#tfy_Ar_mark").focus();
        return false;
    }

    if (IsEmpty($("#F_tscode").val())) {
        alert("洽案營洽不得為空白！");
        settab("#case");
        $("#F_tscode").focus();
        return false;
    }

    //案源代碼檢查
    if (IsEmpty($("#tfy_source").val())) {
        alert("案源代碼不得為空白！");
        settab("#case");
        $("#tfy_source").focus();
        return false;
    }

    //20160910 增加發文方式檢查
    if (IsEmpty($("#tfy_send_way").val())) {
        alert("發文方式不得為空白！");
        settab("#case");
        $("#tfy_send_way").focus();
        return false;
    }

    //20180221 增加電子收據檢查
    //20180619 若規費不是0才要檢查
    if (CInt($("#nfy_fees").val()) != 0) {
        if (IsEmpty($("#tfy_receipt_type").val())) {
            alert("收據種類不得為空白！");
            settab("#case");
            $("#tfy_receipt_type").focus();
            return false;
        }
        if (IsEmpty($("#tfy_receipt_title").val())) {
            alert("收據抬頭不得為空白！");
            settab("#case");
            $("#tfy_receipt_title").focus();
            return false;
        }
    }

    //20180412 增加總契約書檢查
    if ($("#Contract_no_Type_M").prop("checked")) {
        if (IsEmpty($("#Mcontract_no").val())) {
            alert("請選擇總契約書！");
            settab("#case");
            return false;
        }
    }

    var code3 = $("#tfy_Arcase").val().substr(2, 1).toUpperCase();//案性第3碼
    var prt_code = $("#tfy_Arcase option:selected").attr("v1");

    //***其他商標
    if (code3 == "K") {
        var mark2 = $("input[name='tfz1_s_mark2']:checked").val();
        if (mark2 != "H" && mark2 != "I" && mark2 != "J") {
            alert("案性為『其他』時，商標種類只能選『位置、氣味、觸覺』其一");
            return false;
        }
    }

    //***證明標章之證明標的
    if (code3 == "D" || code3 == "E" || code3 == "F" || code3 == "G") {
        var pul = $("input[name='pul']:checked").val();
        if (pul == null) {
            alert("請輸入標章證明標的及內容");
            settab("#tran");
            return false;
        } else {
            $("#tfz1_pul").val(pul);
        }
    }

    //****團體標章表彰之內容	
    if (code3 == "9" || code3 == "A" || code3 == "B" || code3 == "C") {
        if (IsEmpty($("#tf91_good_name").val())) {
            alert("請輸入團體標章表彰之內容");
            settab("#tran");
            return false;
            $("#tf91_good_name").focus();
        }
    }

    //****優先權申請日檢查	
    if (!IsEmpty($("#pfz1_prior_date").val()) && !$.isDate($("#pfz1_prior_date").val())) {
        alert("請檢查優先權申請日，日期格式是否正確!!");
        settab("#tran");
        return false;
        $("#pfz1_prior_date").focus();
    }

    //折扣請核單檢查2005/10/11雄商平淑提出與李經理確認修改如下
    //折扣率>=30檢查需附折扣請核單，為因應折扣率21~29仍需附折扣請款單，不控制>=30勾選材存檔，營洽勾選即存檔	
    //2005/11/22李經理指示折扣率>30需簽折扣請核單，服務費等於七折不用簽折扣請核單
    //2016/5/30修改，因折扣請核改為線上，所以不需檢復折扣請核單，判斷>20需填寫折扣理由
    if ($("#nfy_Discount").val() != "" && CInt($("#nfy_Discount").val()) > 20) {
        if ($("#tfy_discount_remark").val() == "") {
            alert("折扣低於8折，應填寫折扣理由，請輸入！");
            settab("#case");
            $("#tfy_discount_remark").focus();
            return false;
        }
    }
    //轉帳費用檢查
    if ($("#tfy_oth_arcase").val() != "") {
        if ($("#nfy_oth_money").val() == "0") {
            alert("有轉帳費用，請輸入轉帳金額，如無轉帳金額，請將轉帳費用修改為”請選擇”!!");
            settab("#case");
            $("#nfy_oth_money").focus();
            return false;
        }
        if ($("#tfy_oth_code").val() == "") {
            alert("有轉帳費用，請輸入轉帳單位，如無轉帳單位，請將轉帳費用修改為”請選擇”!!");
            settab("#case");
            $("#tfy_oth_code").focus();
            return false;
        }
    }
    if (IsNumeric($("#nfy_oth_money").val())) {
        if (CInt($("#nfy_oth_money").val()) > 0) {
            if ($("#tfy_oth_code").val() == "") {
                alert("有轉帳金額，請輸入轉帳單位!!");
                settab("#case");
                $("#tfy_oth_code").focus();
                return false;
            }
        } else if (CInt($("#nfy_oth_money").val()) < 0) {
            alert("轉帳費用不可為負數，請重新輸入!!");
            settab("#case");
            $("#nfy_oth_money").focus();
            return false;
        }
    } else {
        alert("轉帳費用不為數值，請重新輸入!!");
        settab("#case");
        $("#nfy_oth_money").focus();
        return false;
    }

    if ($("#tfy_oth_code").val() != "") {
        if ($("#nfy_oth_money").val() == "0") {
            alert("有轉帳單位，無轉帳金額，請檢查!!");
            settab("#case");
            $("#nfy_oth_money").focus();
            return false;
        }
    }

    //*******客戶期限與承辦期限控制
    if ($("#dfy_cust_date").val() != "") {
        if ($.isDate($("#dfy_cust_date").val()) && $.isDate($("#dfy_pr_date").val())) {
            if (Date.parse($("#dfy_cust_date").val()) < Date.parse($("#dfy_pr_date").val())) {
                $("#dfy_pr_date").val($("#dfy_cust_date").val());
            }
        } else {
            if ($("#dfy_cust_date").val() != "" && !$.isDate($("#dfy_cust_date").val())) {
                alert("客戶期限日期格式錯誤，請重新輸入!!");
                settab("#case");
                $("#dfy_cust_date").focus();
                return false;
            }
            if ($("#dfy_pr_date").val() != "" && !$.isDate($("#dfy_pr_date").val())) {
                alert("承辦期限日期格式錯誤，請重新輸入!!");
                settab("#case");
                $("#dfy_pr_date").focus();
                return false;
            }
        }
    }

    //*****法定期限控制2011/9/26新增
    if ($("#dfy_last_date").val() != "") {
        if (!$.isDate($("#dfy_last_date").val())) {
            alert("法定期限日期格式錯誤，請重新輸入!!");
            settab("#case");
            $("#dfy_last_date").focus();
            return false;
        }
        if ($("#tfy_case_stat").val() == "OO" || $("#spe_ctrl3").val() == "N") {
            var msg = "提醒您！在此輸入法定期限，系統不會自動管制或檢核程序管制法定期限是否一致，是否確定輸入？";
            if (confirm(msg)) {
                alert("請自行通知程序於客收時加管此法定期限！");
            } else {
                $("#dfy_last_date").val("");
            }
        }
    }

    //*****契約號碼控制
    var cont_type = $("input[name='Contract_no_Type']:checked").val();
    $("#tfy_contract_type").val(cont_type);
    if (cont_type == "A" || cont_type == "B" || cont_type == "C")//後續案無契約書/特案簽報/其他契約書無編號/特案簽報
        $("#tfy_Contract_no").val(cont_type);
    else if (cont_type == "M")//總契約書
        $("#tfy_Contract_no").val($("#Mcontract_no").val());
    else if (cont_type == "N") {//一般契約書
        if ($("#tfy_Contract_no").val() != "") {
            if (!IsNumeric($("#tfy_Contract_no").val())) {
                alert("契約號碼請輸入數值!!");
                settab("#case");
                $("#tfy_Contract_no").focus();
                return false;
            }
        }
    }

    if (main.prgid == "brt52") {//交辦維護
        if ($("input[name='Contract_no_Type']:checked").length == 0) {
            alert("請輸入契約書種類！！！");
            settab("#case");
            $("input[name='Contract_no_Type']")[0].focus();
            return false;
        } else {
            var cont_type = $("input[name='Contract_no_Type']:checked").val();
            if (cont_type == "N") {//一般契約書
                if ($("#tfy_Contract_no").val() == "") {
                    alert("請輸入契約號碼!!");
                    settab("#case");
                    $("#tfy_Contract_no").focus();
                    return false;
                } else if (!IsNumeric($("#tfy_Contract_no").val())) {
                    alert("契約號碼請輸入數值!!");
                    settab("#case");
                    $("#tfy_Contract_no").focus();
                    return false;
                }
            }
            if (cont_type == "M" && $("#tfy_Contract_no").val() == "") {//總契約書但無契約書號
                if ($("#tfy_contract_flag").pdop("checked") == false) {//無勾選契約書後補
                    alert("無總契約書號，請檢查！");
                    settab("#case");
                    $("input[name='Contract_no_Type'][value='M']").focus();
                    return false;
                }
            }
        }
    }

    //***契約書種類與對應文件種類檢查
    if ($("#tfy_contract_flag").prop("checked") == false) {
        var pchktype = "B"
        if (main.prgid == "brt51") pchktype = "A";
        if (check_doctype("T", $("#tfy_contract_type").val(), pchktype) == true) {
            settab("#case");
            return false;
        }
    } else {
        if ($("#tfy_contract_remark").val() == "") {
            alert("契約書相關文件後補，需填寫尚缺文件說明！");
            settab("#case");
            $("#tfy_contract_remark").focus();
            return false;
        }
    }
    //***交辦內容
    //大陸案請款註記檢查.請款註記:大陸進口案
    if ($("#tfz1_seq1").val() == "M" && $("#tfy_Ar_mark").val() != "X") {
        alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
        settab("#case");
        $("#tfy_Ar_mark").focus();
        return false;
    } else if ($("#tfz1_seq1").val() != "M" && $("#tfy_Ar_mark").val() == "X") {
        alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
        settab("#tran");
        $("#tfz1_seq1").focus();
        return false;
    }
    //商標名稱檢查
    if ($("#tfz1_Appl_name").val() == "") {
        alert("需填寫商標名稱！");
        settab("#tran");
        $("#tfz1_Appl_name").focus();
        return false;
    }
    //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
    if (check_CustWatch("appl_name", $("#tfz1_Appl_name").val()) == true) {
        settab("#tran");
        $("#tfz1_Appl_name").focus();
        return false;
    }
    //檢查備註,有選擇radio則須輸入內容
    var z = $('input[name=ttz1_RCode]:checked').val();
    if (z !== undefined && $("#ttz1_" + z).val() == "") {
        alert("請確認備註是否錯誤!");
        settab("#tran");
        return false;
    }
    //出名代理人檢查
    var apclass_flag = "N";
    for (var capnum = 1; capnum <= CInt($("#apnum").val()) ; capnum++) {
        if ($("#apclass_" + capnum).val().Left(1) == "C") {
            //申請人為外國人則為涉外案
            apclass_flag = "C";
        }
    }
    if (apclass_flag == "C") {
        //2015/10/21修改抓取cust_code.code_type=Tagt_no and mark=C及用function放置於sub/client_chk_agtno.vbs
        if (check_agtno("C", $("#tfz1_agt_no").val()) == true) {
            settab("#tran");
            $("#tfz1_agt_no").focus();
            return false;
        }
    } else {
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2");//案性預設出名代理人
        if (pagt_no == "") {
            //2015/10/21因應104年度出名代理人修改並改抓取cust_code.code_type=Tagt_no and mark=N預設出名代理人
            pagt_no = get_tagtno("N").no;
        }

        if ($("#tfz1_agt_no").val().trim() != pagt_no.trim()) {
            if (!confirm("出名代理人與案性預設出名代理人不同，是否確定交辦？")) {
                settab("#tran");
                $("#tfz1_agt_no").focus();
                return false;
            }
        }
    }


    //*****商品類別檢查
    if ($("#tabbr1").length > 0) {//有載入才要檢查
        var inputCount = 0;
        for (var j = 1; j <= CInt($("#num1").val()) ; j++) {
            if ($("#good_name1_" + j).val() != "" && $("#class1_" + j).val() == "") {
                //有輸入商品名稱,但沒輸入類別
                alert("請輸入類別!");
                settab("#tran");
                $("#class1_" + j).focus();
                return false;
            }

            if (br_form.checkclass(j) == false) {//檢查類別範圍0~45
                $("#class1_" + j).focus();
                return false;
            }
            if ($("#class1_" + j).val() != "") {
                inputCount++;//實際有輸入才要+
            }
        }
        $("#ctrlcount1").val(inputCount == 0 ? "" : inputCount);

        if (CInt($("#tfz1_class_count").val()) != CInt($("#num1").val())) {
            var answer = "指定使用商品類別項目(共 " + CInt($("#tfz1_class_count").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num1").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num1").val()) + " 類？";
            if (answer) {
                $("#tfz1_class_count").val($("#num1").val());
            } else {
                settab("#tran");
                $("#tfz1_class_count").focus();
                return false;
            }
        }
    }

    if (code3 == "9" || code3 == "A" || code3 == "B" || code3 == "C" || code3 == "D" || code3 == "E" || code3 == "F" || code3 == "G") {
        $("#tfz1_class").val("");
        $("#tfz1_class_count").val("");
        $("input[name='tfz1_class_type']").prop("checked", false);
    }

    //檢查指定類別有無重覆
    var objClass = {};
    for (var r = 1; r <= CInt($("#num1").val()) ; r++) {
        var lineTa = $("#class1_" + r).val();
        if (lineTa != "" && objClass[lineTa]) {
            alert("商品類別重覆,請重新輸入!!!");
            $("#class1_" + r).focus();
            return false;
        } else {
            objClass[lineTa] = { flag: true, idx: r };
        }
    }

    //***表彰內容
    if ($("#tf91_good_name").length > 0)
        $("#tfz1_good_name").val($("#tf91_good_name").val());
    //***證明內容
    if ($("#tfd1_good_name").length > 0)
        $("#tfz1_good_name").val($("#tfd1_good_name").val());

    //****請款註記	
    if ($("#tfz1_seq1").val() == "M") {
        $("#tfy_ar_code").val("M");
    } else if ($("#nfy_service").val() == 0 && $("#nfy_fees").val() == 0 && $("#nfy_oth_money").val() == 0 && $("#tfy_Ar_mark").val() == "N") {
        $("#tfy_ar_code").val("X");
    } else {
        $("#tfy_ar_code").val("N");
    }

    //****總計案性數
    var nfy_tot_case = 0;
    if (!IsEmpty($("#tfy_Arcase").val())) {
        nfy_tot_case += 1;
    }
    for (var r = 1; r <= CInt($("#TaCount").val()) ; r++) {
        if (!IsEmpty($("#nfyi_item_Arcase_" + r).val())) {
            nfy_tot_case += 1;
        }
    }
    $("#nfy_tot_case").val(nfy_tot_case);

    //****當無收費標準時，把值清空
    if (reg.anfees.value == "N") {
        $("#nfy_Discount").val("");
        $("#tfy_dicount_remark").val("");//2016/5/30增加折扣理由
    }

    return true;
}
