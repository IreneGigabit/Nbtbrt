//日期格式檢查,抓class=dateField,有輸入則檢查
main.chkDate = function (tabName) {
    var rtn = true;
    $("[id='" + tabName + "'] input.dateField").each(function () {
        if ($(this).val() != "" && !$.isDate($(this).val())) {
            $(this).addClass("chkError");
            settab(tabName);
            rtn = false;
        } else {
            $(this).removeClass("chkError");
        }
    });

    return rtn;
}

//客戶聯絡人檢查
main.chkCustAtt = function () {
    if ($("#tfy_case_stat").val() != "OO") {//新案
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
    }
    //聯絡人檢查
    if (IsEmpty($("#tfy_att_sql").val())) {
        alert("聯絡人資料不得為空白！");
        settab("#attent");
        $("#tfy_att_sql").focus();
        return false;
    }
    return true;
}

//申請人檢查
main.chkApp = function () {
    //申請人檢查
    switch ($("#tfy_Arcase").val()) {
        case "FC1": case "FC10": case "FC11": case "FC9": case "FC7":
        case "FC5": case "FCA": case "FCB": case "FCF": case "FCH":
            //apcust_fc_re1_form
            if (CInt($("#FC2_apnum").val()) == 0) {
                alert("請輸入申請人資料！");
                settab("#apcust");
                $("#FC2_AP_Add_button").focus();
                return false;
            }
            for (var tapnum = 1; tapnum <= CInt($("#FC2_apnum").val()) ; tapnum++) {
                if (IsEmpty($("#dbmn1_new_no_" + tapnum).val())) {
                    alert("申請人編號不得為空白！");
                    settab("#apcust");
                    $("#dbmn1_new_no_" + tapnum).focus();
                    return false;
                }
                $("#dbmn1_ap_cname_" + tapnum).val($("#dbmn1_ncname1_" + tapnum).val() + $("#dbmn1_ncname2_" + tapnum).val());
                $("#dbmn1_ap_ename_" + tapnum).val($("#dbmn1_nename1_" + tapnum).val() + " " + $("#dbmn1_nename2_" + tapnum).val());
                if ($("#dbmn1_ncname1_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn1_ncname1_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn1_ncname1_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#dbmn1_ncname2_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn1_ncname2_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn1_ncname2_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#dbmn1_nename1_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn1_nename1_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn1_nename1_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#dbmn1_nename2_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn1_nename2_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn1_nename2_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#tfy_case_stat").val() != "OO") {//新案
                    //2014/4/22增加檢查是否為雙邊代理查照對象
                    if (cust_name_chk($("#dbmn1_ap_cname_" + tapnum).val(), $("#dbmn1_ap_ename_" + tapnum).val())) {
                        settab("#apcust");
                        return false;
                    }
                    if (aprep_name_chk($("#dbmn1_ncrep_" + tapnum).val(), $("#dbmn1_nerep_" + tapnum).val())) {
                        settab("#apcust");
                        return false;
                    }
                }
            }
            break;
        case "FC2": case "FC20": case "FC21": case "FC0": case "FC6":
        case "FC8": case "FCC": case "FCD": case "FCG": case "FCI":
            //apcust_fc_re_form
            //2010/10/5增加控制需填寫申請人種類才能存檔
            if ($("input[name=tfzd_Mark]:checked").length == 0) {
                alert("請選擇申請人變更種類！");
                settab("#apcust");
                $("input[name=tfzd_class_type]").eq(0).focus();
                return false;
            }
            if (CInt($("#FC0_apnum").val()) == 0) {
                alert("請輸入申請人資料！");
                settab("#apcust");
                return false;
            }
            for (var tapnum = 1; tapnum <= CInt($("#FC0_apnum").val()) ; tapnum++) {
                if (IsEmpty($("#dbmn_new_no_" + tapnum).val())) {
                    alert("申請人編號不得為空白！");
                    settab("#apcust");
                    $("#dbmn_new_no_" + tapnum).focus();
                    return false;
                }
                $("#dbmn_ap_cname_" + tapnum).val($("#dbmn_ncname1_" + tapnum).val() + $("#dbmn_ncname2_" + tapnum).val());
                $("#dbmn_ap_ename_" + tapnum).val($("#dbmn_nename1_" + tapnum).val() + " " + $("#dbmn_nename2_" + tapnum).val());
                if ($("#dbmn_ncname1_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn_ncname1_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn_ncname1_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#dbmn_ncname2_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn_ncname2_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn_ncname2_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#dbmn_nename1_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn_nename1_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn_nename1_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#dbmn_nename2_" + tapnum).val() != "") {
                    if (fDataLen($("#dbmn_nename2_" + tapnum))) {
                        settab("#apcust");
                        $("#dbmn_nename2_" + tapnum).focus();
                        return false;
                    }
                }
                if ($("#tfy_case_stat").val() != "OO") {//新案
                    //2014/4/22增加檢查是否為雙邊代理查照對象
                    if (cust_name_chk($("#dbmn_ap_cname_" + tapnum).val(), $("#dbmn_ap_ename_" + tapnum).val())) {
                        settab("#apcust");
                        return false;
                    }
                    if (aprep_name_chk($("#dbmn_ncrep_" + tapnum).val(), $("#dbmn_nerep_" + tapnum).val())) {
                        settab("#apcust");
                        return false;
                    }
                }
            }
            break;
        default:
            //apcust_form
            if (CInt($("#apnum").val()) == 0) {
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
                if ($("#tfy_case_stat").val() != "OO") {//新案
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
            }
            break;
    }

    return true;
}

//商標名稱檢查
main.chkApplName = function () {
    switch ($("#tfy_Arcase").val()) {
        case "DR1":
            if ($("#fr1_appl_name").val() == "") {
                alert("商標名稱不可空白！");
                settab("#tran");
                $("#fr1_appl_name").focus();
                return false;
            }
            //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
            if (check_CustWatch("appl_name", $("#fr1_appl_name").val()) == true) {
                settab("#tran");
                $("#fr1_appl_name").focus();
                return false;
            }
            break;
        case "DO1":
            if ($("#fr2_appl_name").val() == "") {
                alert("商標名稱不可空白！");
                settab("#tran");
                $("#fr2_appl_name").focus();
                return false;
            }
            //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
            if (check_CustWatch("appl_name", $("#fr2_appl_name").val()) == true) {
                settab("#tran");
                $("#fr2_appl_name").focus();
                return false;
            }
            break;
        case "DI1":
            if ($("#fr3_appl_name").val() == "") {
                alert("商標名稱不可空白！");
                settab("#tran");
                $("#fr3_appl_name").focus();
                return false;
            }
            //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
            if (check_CustWatch("appl_name", $("#fr3_appl_name").val()) == true) {
                settab("#tran");
                $("#fr3_appl_name").focus();
                return false;
            }
            break;
        default:
            if ($("#tfzd_appl_name").val() == "") {
                alert("商標名稱不可空白！");
                settab("#dmt");
                $("#tfzd_appl_name").focus();
                return false;
            }
            if ($("#tfy_case_stat").val() == "NN" || $("#tfy_case_stat").val() == "SN") {
                //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
                if (check_CustWatch("appl_name", $("#tfzd_appl_name").val()) == true) {
                    settab("#dmt");
                    $("#tfzd_appl_name").focus();
                    return false;
                }
            }
            break;
    }

    return true;
}

//必填欄位檢查
main.chkRequire = function () {
    //案性檢查
    if (IsEmpty($("#tfy_Arcase").val())) {
        alert("客收/請款案性不得為空白！");
        settab("#case");
        $("#tfy_Arcase").focus();
        return false;
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

    //特定案性才要檢查
    if (main.ar_form == "A4") {//延展
        if (IsEmpty($("#tfzd_issue_no").val())) {
            alert("註冊號數不得為空白！");
            settab("#dmt");
            $("#tfzd_issue_no").focus();
            return false;
        }
    } else if (main.ar_form == "A5") {//分割
        if (IsEmpty($("#tfzd_apply_date").val())) {
            alert("分割案：法令規定子案與母案申請日相同，請輸入申請日！");
            settab("#dmt");
            $("#tfzd_apply_date").focus();
            return false;
        }
    } else if (main.ar_form == "A6") {//變更
        if ($("#tfy_Arcase").val().Left(3) == "FC2" || $("#tfy_Arcase").val().Left(3) == "FC0"
            || $("#tfy_Arcase").val().Left(3) == "FC6" || $("#tfy_Arcase").val().Left(3) == "FC8"
            || $("#tfy_Arcase").val().Left(3) == "FCC" || $("#tfy_Arcase").val().Left(3) == "FCD"
            || $("#tfy_Arcase").val().Left(3) == "FCG" || $("#tfy_Arcase").val().Left(3) == "FCI") {
            if (IsEmpty($("#tfzd_issue_no").val())) {
                alert("註冊號數不得為空白！");
                settab("#dmt");
                $("#tfzd_issue_no").focus();
                return false;
            }
        }
    } else if (main.ar_form == "A7") {//授權
        if (IsEmpty($("#tfzd_issue_no").val())) {
            if (confirm("註冊號數為空白，確定交辦？") == false) {
                settab("#dmt");
                $("#tfzd_issue_no").focus();
                return false;
            }
        }
    } else if (main.ar_form == "A8") {//移轉
        if (IsEmpty($("#tfzd_issue_no").val()) && IsEmpty($("#tfzd_apply_no").val())) {
            alert("註冊號數不得為空白！");
            settab("#dmt");
            $("#tfzd_issue_no").focus();
            return false;
        }
    } else if (main.ar_form == "A9") {//質權
        if ($("#tfy_Arcase").val().Left(3) == "FP1") {
            if (IsEmpty($("#tfg1_debit_money").val())) {
                alert("債權額度不得為空白！");
                settab("#tran");
                $("#tfg1_debit_money").focus();
                return false;
            }
        }else if ($("#tfy_Arcase").val().Left(3) == "FP2") {
            if (IsEmpty($("#tfg2_term1").val())) {
                alert("質權消滅日期不得為空白！");
                settab("#tran");
                $("#tfg2_term1").focus();
                return false;
            }
        }
    } else if (main.ar_form == "AA") {//各種證明書
        if ($("input[name=tfzd_Mark]").eq(0).prop("checked") == true) {
            if (IsEmpty($("#tfzd_apply_no").val())) {
                alert("申請號數不可以空白！");
                settab("#dmt");
                $("#tfzd_apply_no").focus();
                return false;
            }
        } else if ($("input[name=tfzd_Mark]").eq(1).prop("checked") == true) {
            if (IsEmpty($("#tfzd_issue_no").val())) {
                alert("註冊號數不可以空白！");
                settab("#dmt");
                $("#tfzd_issue_no").focus();
                return false;
            }
        }
    } else if (main.ar_form == "AB") {//補(換)發證
        if (IsEmpty($("#tfzd_issue_no").val())) {
            alert("註冊號數不得為空白！");
            settab("#dmt");
            $("#tfzd_issue_no").focus();
            return false;
        }
    } else if (main.ar_form == "AC") {//閱案
        if ($("input[name=tfzd_Mark]").eq(0).prop("checked") == true) {
            if (IsEmpty($("#tfzd_apply_no").val())) {
                alert("申請號數不可以空白！");
                settab("#dmt");
                $("#tfzd_apply_no").focus();
                return false;
            }
        } else if ($("input[name=tfzd_Mark]").eq(1).prop("checked") == true) {
            if (IsEmpty($("#tfzd_issue_no").val())) {
                alert("註冊號數不可以空白！");
                settab("#dmt");
                $("#tfzd_issue_no").focus();
                return false;
            }
        }
    }

    return true;
}

//接洽內容相關檢查
main.chkCaseForm = function () {
    //案性檢查
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

    //20180619 若規費不是0才要檢查
    if (CInt($("#nfy_fees").val()) != 0) {
        //20180221 增加電子收據檢查
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
        }
    }

    //*****法定期限控制2011/9/26新增,新立案且交辦特定案性輸入法定期限
    if ($("#dfy_last_date").val() != "") {
        if ($("#tfy_case_stat").val() == "OO" || $("#spe_ctrl3").val() == "N") {
            var msg = "提醒您！在此輸入法定期限，系統不會自動管制或檢核程序管制法定期限是否一致，是否確定輸入？";
            if (confirm(msg)) {
                alert("請自行通知程序於客收時加管此法定期限！");
            } else {
                $("#dfy_last_date").val("");
            }
        }
    } else {
        if ($("#prt_code") == "B" || $("#prt_code") == "ZZ") {
            if ($("#tfy_case_stat").val() == "NN" || $("#tfy_case_stat").val() == "SN") {
                if ($("#spe_ctrl3").val() == "Y") {
                    alert("請輸入法定期限！");
                    settab("#case");
                    $("#dfy_last_date").focus();
                    return false;
                }
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
    //***契約書種類與對應文件種類檢查
    if ($("#tfy_contract_flag").prop("checked") == false) {
        var pchktype = "B"
        if (main.prgid == "brt51") pchktype = "A";////客收確認
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

    return true;
}

//新/舊案號
main.chkNewOld = function () {
    if ($("#tfy_case_stat").val() == "NN") {
        //$("#tfzb_seq").val($("#New_seq").val());
        $("#tfzb_seq").val("");
        $("#tfzb_seq1").val($("#New_seq1").val());
    } else if ($("#tfy_case_stat").val() == "SN") {
        $("#tfzb_seq").val($("#New_Ass_seq").val());
        $("#tfzb_seq1").val($("#New_Ass_seq1").val());
        if (IsEmpty($("#New_Ass_seq").val())) {
            alert("案件編號不得為空白，請重新輸入");
            settab("#dmt");
            $("#New_Ass_seq").focus();
            return false;
        }
        if (IsEmpty($("#New_Ass_seq1").val())) {
            alert("案件編號副碼不得為空白，請重新輸入");
            settab("#dmt");
            $("#New_Ass_seq1").focus();
            return false;
        }
    } else if ($("#tfy_case_stat").val() == "OO") {
        $("#tfzb_seq").val($("#old_seq").val());
        $("#tfzb_seq1").val($("#old_seq1").val());
        if (IsEmpty($("#old_seq").val())) {
            alert("當案件為舊案時，請輸入『案件編號』及按下『確定』以取得詳細資料!");
            settab("#dmt");
            $("#old_seq").focus();
            return false;
        }
    }
    if ($("#tfy_case_stat").val() == "OO") {
        if ($("#keyseq").val() == "N") {
            alert("主案件編號變動過，請按[確定]按鈕，重新抓取資料!!!");
            settab("#dmt");
            $("#btnseq_ok").focus();
            return false;
        }
    }

    return true;
}

//主檔商品類別檢查
main.chkGood = function () {
    //*****主檔商品類別檢查
    var pname = $("#tfzr_class_count").val();//共N類
    if (pname != "") {
        //2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
        if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
            var inputCount = 0;
            for (var j = 1; j <= CInt($("#num1").val()) ; j++) {
                if ($("#good_name1_" + j).val() != "" && $("#class1_" + j).val() == "") {
                    //有輸入商品名稱,但沒輸入類別
                    alert("請輸入類別!");
                    settab("#dmt");
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
        }
        $("#ctrlcount1").val(inputCount == 0 ? "" : inputCount);
        if (CInt(pname) != CInt($("#num1").val())) {
            var answer = "指定使用商品類別項目(共 " + CInt(pname) + " 類)與輸入指定使用商品(共 " + CInt($("#num1").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num1").val()) + " 類？";
            if (answer) {
                $("#tfzr_class_count").val($("#num1").val());
            } else {
                settab("#tran");
                $("#tfzr_class_count").focus();
                return false;
            }
        }
    }
    return true;
}

//結案復案檢查
main.chkEndBack = function () {
    //2011/1/24將交辦畫面之結案及復案資料傳至資料庫存入欄位
    dmt_form.get_enddata("A9Z");//結案資料
    dmt_form.get_backdata("A9Z");//復案資料
    //2010/6/7因結案流程修改，交辦結案要輸入結案原因
    //2010/10/5增加結案註記,由營洽勾選是否要結案，要結案才檢查要輸入原因
    //2011/1/24增加交辦其他案性也可結案及復案註記，修改資料檢查條件
    if ($("#tfy_case_stat").val() == "OO") {
        //2011/1/24是否復案由營洽自行決定
        if ($("#tfy_Arcase").val().Left(2) != "XX") {
            if ($("#tfy_back_flag").val() == "N" || $("#tfy_back_flag").val() == "") {
                if ($("#tfzd_end_date").val() != "") {
                    var answer = "該案件已結案，如確定要交辦則需註記是否復案，是否確定不復案？\n※如有結案程序未完成，復案後系統將自動取消結案流程並銷管結案期限。";
                    if (confirm(answer) == false) {
                        return false;
                    }
                }
                if ($("#todoend_flag").val() == "Y") {
                    var answer = "該案件已進行結案程序，如確定要交辦則需註記是否復案，是否確定不復案？\n※復案後系統將自動取消結案流程並銷管結案期限。";
                    if (confirm(answer) == false) {
                        return false;
                    }
                }
            }
        }
        if ($("#tfy_end_flag").val() == "Y" && $("#tfy_back_flag").val() == "Y") {
            alert("該案件無法同時復案及結案，請重新勾選！");
            return false;
        }
        //結案註記檢查
        if ($("#tfy_end_flag").val() == "Y") {
            if ($("#tfzd_end_date").val() != "" || $("#todoend_flag").val() == "Y") {
                var answer = "該案件已結案或結案程序進行中，是否確定仍需勾選結案註記？";
                if (confirm(answer) == false) {
                    return false;
                }
            }
            if ($("#tfy_end_type").val() == "") {
                alert("請點選「結案原因」！若不結案，請取消勾選「結案註記」。");
                return false;
            }
            if ($("#tfy_end_type").val() == "016") {
                if ($("#tfy_end_remark").val().trim() == "") {
                    alert("請輸入「結案原因」！");
                    return false;
                }
            }
        } else {
            if ($("#tfy_end_type").val() != "") {
                alert("輸入結案原因但未勾選結案註記，確定結案請一併勾選「結案註記」，若不結案，請將「結案原因」修改為請選擇！");
                return false;
            }
        }
        //復案註記檢查
        if ($("#tfy_back_flag").val() == "Y") {
            if ($("#tfzd_end_date").val() == "" || $("#todoend_flag").val() == "N") {
                var answer = "該案件未結案也無結案程序進行中，是否確定仍需勾選復案註記？";
                if (confirm(answer) == false) {
                    return false;
                }
            }
            if ($("#tfy_back_remark").val() == "") {
                alert("請輸入「復案原因」。");
                return false;
            }
        } else {
            if ($("#tfy_back_remark").val() != "") {
                alert("輸入復案原因但未勾選復案註記，確定復案請一併勾選「復案註記」，若不復案，請將「復案原因」清空！");
                return false;
            }
        }
    } else {
        if ($("#tfy_end_flag").val() == "Y" || $("#tfy_back_flag").val() == "Y") {
            alert("新立案不能勾選結案或復案註記，請檢查！");
            return false;
        }
        $("#tfy_end_flag").val("N");
        $("#tfy_end_type").val("");
        $("#tfy_end_remark").val("");
        $("#tfy_back_flag").val("N");
        $("#tfy_back_remark").val("");
    }

    $("#tfzd_end_code").val($("#tfzy_end_code").val());

    return true;
}

//出名代理人檢查,num=申請人計數欄位名(ex:apnum),apclass=申請人欄位名(ex:ttg1_apclass),tran_agt_no=交辦畫面的代理人欄位名(ex:ttg1_agt_no)
main.chkAgt = function (num,apclass, tran_agt_no) {
    var apclass_flag = "N";

    for (var capnum = 1; capnum <= CInt($("#" + num).val()) ; capnum++) {
        if ($("#" + apclass + "_" + capnum).val().Left(1) == "C") {
            //申請人為外國人則為涉外案
            apclass_flag = "C";
        }
    }
    if (apclass_flag == "C") {
        //2015/10/21修改抓取cust_code.code_type=Tagt_no and mark=C及用function放置於sub/client_chk_agtno.vbs
        if (check_agtno("C", $("#" + tran_agt_no).val()) == true) {
            settab("#tran");
            $("#" + tran_agt_no).focus();
            return false;
        }
    } else {
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2");//案性預設出名代理人
        if (pagt_no == "") {
            //2015/10/21因應104年度出名代理人修改並改抓取cust_code.code_type=Tagt_no and mark=N預設出名代理人
            pagt_no = get_tagtno("N").no;
        }

        if ($("#" + tran_agt_no).val().trim() != pagt_no.trim()) {
            if (!confirm("出名代理人與案性預設出名代理人不同，是否確定交辦？")) {
                settab("#tran");
                $("#" + tran_agt_no).focus();
                return false;
            }
        }
    }
    if (tran_agt_no != "tfzd_agt_no") {
        $("#tfzd_agt_no").val($("#" + tran_agt_no).val());
    }

    return true;
}

//檢查大陸案請款註記檢查&給值
main.chkAr = function () {
    //大陸案請款註記檢查.請款註記:大陸進口案
    if ($("#tfzb_seq1").val() == "M" && $("#tfy_Ar_mark").val() != "X") {
        alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
        settab("#case");
        $("#tfy_Ar_mark").focus();
        return false;
    } else if ($("#tfzb_seq1").val() != "M" && $("#tfy_Ar_mark").val() == "X") {
        alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
        settab("#tran");
        if ($("#tfy_case_stat").val() == "NN") {
            $("#New_seq1").focus();
        } else if ($("#tfy_case_stat").val() == "OO") {
            $("#old_seq1").focus();
        }
        return false;
    }
    //****請款註記給值
    if ($("#tfzb_seq1").val() == "M") {
        $("#tfy_ar_code").val("M");
    } else if ($("#nfy_service").val() == 0 && $("#nfy_fees").val() == 0 && $("#nfy_oth_money").val() == 0 && $("#tfy_Ar_mark").val() == "N") {
        $("#tfy_ar_code").val("X");
    } else {
        $("#tfy_ar_code").val("N");
    }

    //****當無收費標準時，把值清空
    if ($("#anfees").val()== "N") {
        $("#nfy_Discount").val("");
        $("#tfy_dicount_remark").val("");//2016/5/30增加折扣理由
    }
}

//存檔檢查
main.savechkA3 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkA4 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfzd_agt_no") == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;


    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfgp_seq").val($("#tfzb_seq").val());
    $("#tfgp_seq1").val($("#tfzb_seq1").val());

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Mark").val($("input[name='tfzy_mark']:checked").val());
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //指定類別檢查
    if ($("#tfzd_class_count").val() != "") {
        //2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
        if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
            if ($("input[name='tfzd_class_type']:checked").length == 0) {
                alert("請點選類別種類(國際分類或舊類)！！");
                settab("#tran");
                $("input[name=tfzd_class_type]").eq(0).focus();
                return false;
            }
            var inputCount = 0;
            for (var j = 1; j <= CInt($("#num2").val()) ; j++) {
                if ($("#good_name2_" + j).val() != "" && $("#class2_" + j).val() == "") {
                    //有輸入商品名稱,但沒輸入類別
                    alert("請輸入類別!");
                    settab("#tran");
                    $("#class2_" + j).focus();
                    return false;
                }
                if (br_form.checkclass(j) == false) {//檢查類別範圍0~45
                    $("#class2_" + j).focus();
                    settab("#tran");
                    return false;
                }
                if ($("#class2_" + j).val() != "") {
                    inputCount++;//實際有輸入才要+
                }
            }
        }
        //檢查指定類別有無重覆
        var objClass = {};
        for (var r = 1; r <= CInt($("#num2").val()) ; r++) {
            var lineTa = $("#class2_" + r).val();
            if (lineTa != "" && objClass[lineTa]) {
                alert("商品類別重覆,請重新輸入!!!");
                $("#class2_" + r).focus();
                return false;
            } else {
                objClass[lineTa] = { flag: true, idx: r };
            }
        }
        $("#ctrlcount2").val(inputCount == 0 ? "" : inputCount);
        if (CInt($("#tfzd_class_count").val()) != CInt($("#num2").val())) {
            var answer = "指定使用商品類別項目(共 " + CInt($("#tfzd_class_count").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num2").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num2").val()) + " 類？";
            if (answer) {
                $("#tfzd_class_count").val($("#num2").val());
            } else {
                settab("#tran");
                $("#tfzd_class_count").focus();
                return false;
            }
        }
    }

    //變更項目
    $("#tfgp_mod_agttype").val($("input[name='tfzr_mod_agttype']:checked").val() || "N");
    var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_pul", "mod_oth", "mod_oth1", "mod_oth2", "mod_dmt"];
    for (var m in arr_mod) {
        if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
            $("#tfgp_" + arr_mod[m]).val("Y");
        } else {
            $("#tfgp_" + arr_mod[m]).val("N");
            if (arr_mod[m] == "mod_agt") {
                $("#tfgp_mod_agttype").val("N");
            }
        }
    }

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //附註檢查
    if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
        if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }

    //20161006增加備註檢查(因應電子送件修改備註.2欄都可存檔)
    if ($("#O_item1").val() != "" && $("input[name=O_item2]").prop("checked").length > 0 && $("input[name=O_item]").eq(0).prop("checked") == false) {
        alert("備註項目(1)未勾選，請檢查");
        return false;
    }
    if ($("#O_item1").val() != "" && $("input[name=O_item2]").prop("checked").length > 0 && $("input[name=O_item]").eq(1).prop("checked") == false) {
        alert("備註項目(2)未勾選，請檢查");
        return false;
    }

    //檢查延展商標權範圍及內容
    if ($("#tfzd_class_count").val() != "" && $("#tfgp_tran_remark2").val() != "") {
        alert("延展商品服務名稱、證明標的及內容、表彰組織及會員之會籍只能輸入一項，煩請檢查");
        settab("#tran");
        $("#tfgp_tran_remark2,#ttr1_R1,#ttr1_R9").val("");
        $("input[name=ttr1_RCode]").prop("checked", false);
        $("#tfzd_class_count").focus();
        return false;
    }

    if ($("#nfy_service").val() == 0 && $("#nfy_fees").val() == 0 && $("#tfy_Ar_mark").val() == "N") {
        $("#tfy_ar_code").val("X");
    }

    return true;
}

main.savechkA5 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    switch ($("#tfy_Arcase").val().Left(3)) {
        case "FD1":
            //出名代理人檢查
            if (main.chkAgt("apnum", "apclass", "ttg1_agt_no") == false) return false;

            if (IsEmpty($("#tfg1_div_arcase").val())) {
                alert("請選擇分割後案性");
                settab("#tran");
                $("#tfg1_div_arcase").focus();
                return false;
            } else {
                $("#tfy_div_arcase").val($("#tfg1_div_arcase").val());
            }

            if (IsEmpty($("#tot_num1").val())) {
                alert("請輸入分割件數");
                settab("#tran");
                $("#tot_num1").focus();
                return false;
            } else {
                $("#nfy_tot_num").val($("#tot_num1").val());
            }

            if ($("#ttz1_Z2").prop("checked") == true) {
                if ($("#ttz1_Z2C").val() == "") {
                    alert("附件二有勾選，請輸入按分割件數之分割申請書副本份數");
                    settab("#tran");
                    $("#ttz1_Z2C").focus();
                }
            }
            if ($("#ttz1_Z3").prop("checked") == true) {
                if ($("#ttz1_Z3C").val() == "") {
                    alert("附件三有勾選，請輸入分割後之商標註冊申請書正本及其相關文件份數");
                    settab("#tran");
                    $("#ttz1_Z3C").focus();
                }
            }
            //***指定類別數目檢查
            var inputCount = $("[id^='FD2_class_count_'][value!='']").length;//有輸入類別的件數
            if (inputCount == 0) {
                alert("有分割件數，但無輸入分割商品/服務類別、名稱、證明內容及標的，請輸入！！！");
                settab("#tran");
                $("#FD2_class_count_1").focus();
                return false;
            }

            if (CInt($("#tot_num1").val()) != 0) {
                var pname = CInt($("#tot_num1").val());//分割為N件
                var kname = $("[id^='FD1_class_count_'][value!='']").length;//有輸入類別的件數
                if (pname != kname) {
                    var answer = "分割件數(共 " + pname + " 類)與輸入分割後類別項目(共 " + kname + " 類)不符，\n是否確定分割後類別項目共 " + kname + " 類？";
                    if (answer) {
                        $("#tot_num1").val(kname).triggerHandler("change");
                    } else {
                        settab("#tran");
                        $("#tot_num1").focus();
                        return false;
                    }
                }
            }

            for (var a = 1; a <= CInt($("#tot_num1").val()) ; a++) {
                var class_cnt = $("#FD1_class_count_" + a).length;//該分割輸入的共N類
                var input_cnt = $("[id^='classa_" + a + "_'][value!='']").length;//該分割實際有輸入的類別數量

                if (class_cnt != input_cnt) {
                    var answer = "分割後指定使用商品類別項目" + a + "(共 " + class_cnt + " 類)與輸入指定使用商品(共 " + input_cnt + " 類)不符，\n是否確定指定使用商品共 " + input_cnt + " 類？";
                    if (answer) {
                        $("#FD1_class_count_" + a).val(input_cnt).triggerHandler("change");
                    } else {
                        settab("#tran");
                        $("#FD1_class_count_" + a).focus();
                        return false;
                    }
                }
            }

            for (var a = 1; a <= CInt($("#tot_num1").val()) ; a++) {
                if ($("input[name='FD1_Marka_" + a + "']:checked").length == 0) {
                    alert("請選擇分割" + NumberToCh(a) + "名稱種類：");
                    settab("#tran");
                    $("input[name=FD1_Marka_" + a + "']").eq(0).focus();
                    return false;
                }

                //檢查指定類別有無重覆
                var objClass = {};
                for (var r = 1; r <= CInt($("#FD1_class_count_" + a).val()) ; r++) {
                    var lineTa = $("#classa_" + a + "_" + r).val();
                    if (lineTa != "" && objClass[lineTa]) {
                        alert("商品類別重覆,請重新輸入!!!");
                        $("#classa_" + a + "_" + r).focus();
                        return false;
                    } else {
                        objClass[lineTa] = { flag: true, idx: r };
                    }
                }
            }

            //附註檢查
            if ($("#O_item11").val() == "" && $("input[name=O_item12]").prop("checked").length > 0) {
                if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
                    settab("#tran");
                    $("#O_item11").focus();
                    return false;
                }
            }
            break;

        case "FD2": case "FD3":
            //出名代理人檢查
            if (main.chkAgt("apnum", "apclass", "ttg2_agt_no") == false) return false;

            if (IsEmpty($("#tot_num2").val())) {
                alert("請輸入分割件數");
                settab("#tran");
                $("#tot_num2").focus();
                return false;
            } else {
                $("#nfy_tot_num").val($("#tot_num2").val());
            }

            if ($("#ttz2_Z2").prop("checked") == true) {
                if ($("#ttz2_Z2C").val() == "") {
                    alert("附件二有勾選，請輸入按分割件數之分割申請書副本份數");
                    settab("#tran");
                    $("#ttz2_Z2C").focus();
                }
            }
            //***指定類別數目檢查
            var inputCount = $("[id^='FD2_class_count_'][value!='']").length;//有輸入類別的件數
            if (inputCount == 0) {
                alert("有分割件數，但無輸入分割商品/服務類別、名稱、證明內容及標的，請輸入！！！");
                settab("#tran");
                $("#FD2_class_count_1").focus();
                return false;
            }

            if (CInt($("#tot_num2").val()) != 0) {
                var pname = CInt($("#tot_num2").val());//分割為N件
                var kname = $("[id^='FD2_class_count_'][value!='']").length;//有輸入類別的件數
                if (pname != kname) {//有輸入類別的件數
                    var answer = "分割件數(共 " + pname + " 類)與輸入分割後類別項目(共 " + kname + " 類)不符，\n是否確定分割後類別項目共 " + kname + " 類？";
                    if (answer) {
                        $("#tot_num2").val(kname).triggerHandler("change");
                    } else {
                        settab("#tran");
                        $("#tot_num2").focus();
                        return false;
                    }
                }
            }

            for (var a = 1; a <= CInt($("#tot_num2").val()) ; a++) {
                var class_cnt = $("#FD2_class_count_" + a).length;//該分割輸入的共N類
                var input_cnt = $("[id^='classb_" + a + "_'][value!='']").length;//該分割實際有輸入的類別數量

                if (class_cnt != input_cnt) {
                    var answer = "分割後指定使用商品類別項目" + a + "(共 " + class_cnt + " 類)與輸入指定使用商品(共 " + input_cnt + " 類)不符，\n是否確定指定使用商品共 " + input_cnt + " 類？";
                    if (answer) {
                        $("#FD2_class_count_" + a).val(input_cnt).triggerHandler("change");
                    } else {
                        settab("#tran");
                        $("#FD2_class_count_" + a).focus();
                        return false;
                    }
                }
            }

            for (var a = 1; a <= CInt($("#tot_num2").val()) ; a++) {
                if ($("input[name='FD2_Markb_" + a + "']:checked").length == 0) {
                    alert("請選擇分割" + NumberToCh(a) + "名稱種類：");
                    settab("#tran");
                    $("input[name='FD2_Markb_" + a + "']").eq(0).focus();
                    return false;
                }

                //檢查指定類別有無重覆
                var objClass = {};
                for (var r = 1; r <= CInt($("#FD2_class_count_" + a).val()) ; r++) {
                    var lineTa = $("#classb_" + a + "_" + r).val();
                    if (lineTa != "" && objClass[lineTa]) {
                        alert("商品類別重覆,請重新輸入!!!");
                        $("#classb_" + a + "_" + r).focus();
                        return false;
                    } else {
                        objClass[lineTa] = { flag: true, idx: r };
                    }
                }
            }

            //附註檢查
            if ($("#O_item21").val() == "" && $("input[name=O_item22]").prop("checked").length > 0) {
                if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
                    settab("#tran");
                    $("#O_item21").focus();
                    return false;
                }
            }
            break;
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();

    return true;
}

main.savechkA6 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    if ($("#tfy_Arcase").val().Left(3) == "FC1" || $("#tfy_Arcase").val().Left(3) == "FC9" || $("#tfy_Arcase").val().Left(3) == "FC5"
		|| $("#tfy_Arcase").val().Left(3) == "FC7" || $("#tfy_Arcase").val().Left(3) == "FCA" || $("#tfy_Arcase").val().Left(3) == "FCB"
		|| $("#tfy_Arcase").val().Left(3) == "FCF" || $("#tfy_Arcase").val().Left(3) == "FCH") {
        for (var tapnum = 1; tapnum <= CInt($("#FC1_apnum").val()) ; tapnum++) {
            if ($("#dbmo1_old_no_" + tapnum).val() != "") {
                $("#tft1_old_no_" + tapnum).val($("#dbmo1_old_no_" + tapnum).val());
            }
            if ($("#dbmo1_ocname1_" + tapnum).val() != "") {
                $("#tft1_ocname1_" + tapnum).val($("#dbmo1_ocname1_" + tapnum).val());
            }
            if ($("#dbmo1_ocname2_" + tapnum).val() != "") {
                $("#tft1_ocname2_" + tapnum).val($("#dbmo1_ocname2_" + tapnum).val());
            }
            if ($("#dbmo1_oename1_" + tapnum).val() != "") {
                $("#tft1_oename1_" + tapnum).val($("#dbmo1_oename1_" + tapnum).val());
            } if ($("#dbmo1_oename2_" + tapnum).val() != "") {
                $("#tft1_oename2_" + tapnum).val($("#dbmo1_oename2_" + tapnum).val());
            }
        }
    }

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //****指定使用商品/服務類別及名稱
    if ($("#tfy_Arcase").val().Left(3) != "FC3") {
        //主檔商品類別檢查
        if (main.chkGood() == false) return false;
    } else {
        //指定類別檢查
        if ($("#tft3_class_count2").val() != "") {
            //2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
            if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
                var inputCount = 0;
                for (var j = 1; j <= CInt($("#num32").val()) ; j++) {
                    if ($("#good_name32_" + j).val() != "" && $("#class32_" + j).val() == "") {
                        //有輸入商品名稱,但沒輸入類別
                        alert("請輸入類別!");
                        settab("#tran");
                        $("#class32_" + j).focus();
                        return false;
                    }
                    if (br_form.checkclass(j) == false) {//檢查類別範圍0~45
                        $("#class32_" + j).focus();
                        settab("#tran");
                        return false;
                    }
                    if ($("#class32_" + j).val() != "") {
                        inputCount++;//實際有輸入才要+
                    }
                }
            }
            //檢查指定類別有無重覆
            var objClass = {};
            for (var r = 1; r <= CInt($("#num32").val()) ; r++) {
                var lineTa = $("#class32_" + r).val();
                if (lineTa != "" && objClass[lineTa]) {
                    alert("商品類別重覆,請重新輸入!!!");
                    $("#class32_" + r).focus();
                    return false;
                } else {
                    objClass[lineTa] = { flag: true, idx: r };
                }
            }
            $("#ctrlcount32").val(inputCount == 0 ? "" : inputCount);
            if (CInt($("#tft3_class_count2").val()) != CInt($("#num32").val())) {
                var answer = "指定使用商品類別項目(共 " + CInt($("#tft3_class_count2").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num32").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num32").val()) + " 類？";
                if (answer) {
                    $("#tft3_class_count2").val($("#num32").val());
                } else {
                    settab("#tran");
                    $("#tft3_class_count2").focus();
                    return false;
                }
            }
        }
    }

    //***指定類別數目檢查
    var prt_code = $("#tfy_Arcase option:selected").attr("v1");
    var f = prt_code.substr(2, 1);
    switch ($("#tfy_Arcase").val()) {
        case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
            if (IsEmpty($("#tft1_mod_count" + f + "1").val()) == false) {
                var kname = CInt($("#tft1_mod_count" + f + "1").val());//件數
                var gname = $("[id^='new_no" + f + "'][value!='']").length;//有輸入申請案號的件數

                if (kname != gname) {
                    var answer = "指定件數(共 " + kname + " 類)與輸入件數(共 " + gname + " 類)不符，\n是否確定指定件數共 " + gname + " 類？";
                    if (answer) {
                        $("#tft1_mod_count" + f + "1").val(gname).triggerHandler("change");
                    } else {
                        settab("#tran");
                        $("#tft1_mod_count" + f + "1").focus();
                        return false;
                    }
                }
            }
            var old_no_flag = "N";
            for (var apnum = 1; apnum <= CInt($("#FC1_apnum").val()) ; apnum++) {
                if ($("#dbmo1_old_no_" + apnum).val() != "") {
                    old_no_flag = "Y";
                    break;
                }
            }
            if (old_no_flag == "Y") {
                if ($("input[name='tfzr_mod_ap']").prop("checked") == false) {
                    alert("有申請權利之讓與，請勾選變更事項！！");
                    settab("#tran");
                    $("input[name='tfzr_mod_ap']").focus();
                    return false;
                }
            }
            break;
        case "FC11": case "FC5": case "FC7": case "FCH":
            var old_no_flag = "N";
            for (var apnum = 1; apnum <= CInt($("#FC1_apnum").val()) ; apnum++) {
                if ($("#dbmo1_old_no_" + apnum).val() != "") {
                    old_no_flag = "Y";
                    break;
                }
            }
            if (old_no_flag == "Y") {
                if ($("input[name='tfzr1_mod_ap']").prop("checked") == false) {
                    alert("有申請權利之讓與，請勾選變更事項！！");
                    settab("#tran");
                    $("input[name='tfzr1_mod_ap']").focus();
                    return false;
                }
            }
            break;
        case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
            break;
        case "FC3":
            for (var j = 1; j <= 2; j++) {
                var kname = CInt($("#tft3_class_count" + j).val());//件數
                var gname = $("[id^='class3" + j + "_'][value!='']").length;//有輸入類別的件數

                if (kname != gname) {
                    var errname = "";
                    if (j == 1) errname = "擬減縮"; else if (j == 2) errname = "減縮後指定";
                    var answer = "商品(服務)名稱指定件數(共 " + kname + " 類)與輸入件數(共 " + gname + " 類)不符，\n是否確定指定件數共 " + gname + " 類？";
                    if (answer) {
                        $("#tft3_class_count" + j).val(gname).triggerHandler("change");
                    } else {
                        settab("#tran");
                        $("#tft3_class_count" + j).focus();
                        return false;
                    }
                }
            }
            break;
        case "FC4":
            break;
    }

    //***變更項目*********************
    switch ($("#tfy_Arcase").val()) {
        case "FC1": case "FC10": case "FC9": case "FCA": case "FCB":
            //FC1form
            var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_oth", "mod_oth1", "mod_oth2", "mod_claim1"];
            for (var m in arr_mod) {
                if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
                    $("#tfg1_" + arr_mod[m]).val("Y");
                } else {
                    $("#tfg1_" + arr_mod[m]).val("N");
                }
            }
            break;
        case "FC11": case "FC5": case "FC7": case "FCH":
            //FC11form
            var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_oth", "mod_oth1", "mod_oth2", "mod_claim1"];
            for (var m in arr_mod) {
                if ($("#tfzr1_" + arr_mod[m]).prop("checked") == true) {
                    $("#tfg1_" + arr_mod[m]).val("Y");
                } else {
                    $("#tfg1_" + arr_mod[m]).val("N");
                }
            }
            break;
        case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
            //FC2form
            var arr_mod = ["mod_agt", "mod_oth", "mod_oth1", "mod_dmt", "mod_claim1", "mod_claim2"];
            for (var m in arr_mod) {
                if ($("#tfop_" + arr_mod[m]).prop("checked") == true) {
                    $("#tfg2_" + arr_mod[m]).val("Y");
                } else {
                    $("#tfg2_" + arr_mod[m]).val("N");
                }
            }

            if ($("#tfy_Arcase").val() == "FCC") {
                if ($("#tfg2_mod_agt").val() == "Y") {
                    if ($("input[name=tfg2_mod_agttype]:checked").val() != "A") {
                        alert("交辦註冊事項變更(新增代理人)，代理人異動請點選「新增」！");
                        return false;
                    }
                } else {
                    alert("交辦註冊事項變更(新增代理人)，請於代理人資料前勾選！");
                    return false;
                }
            }

            if ($("#tfy_Arcase").val() == "FCD") {
                if ($("#tfg2_mod_agt").val() == "Y") {
                    if ($("input[name=tfg2_mod_agttype]:checked").val() != "D") {
                        alert("交辦註冊事項變更(撤銷代理人)，代理人異動請點選「撤銷」！");
                        return false;
                    }
                } else {
                    alert("交辦註冊事項變更(撤銷代理人)，請於代理人資料前勾選！");
                    return false;
                }
            }
            break;
        case "FC21": case "FC8": case "FC6": case "FCI":
            //FC21form
            var arr_mod = ["mod_agt", "mod_oth", "mod_oth1", "mod_dmt", "mod_claim1", "mod_claim2"];
            for (var m in arr_mod) {
                if ($("#tfop1_" + arr_mod[m]).prop("checked") == true) {
                    $("#tfg2_" + arr_mod[m]).val("Y");
                } else {
                    $("#tfg2_" + arr_mod[m]).val("N");
                }
            }
            if ($("#tfop1_mod_agttypeC").prop("checked") == true) $("#tfg2_mod_agttypeC").prop("checked", true);
            if ($("#tfop1_mod_agttypeA").prop("checked") == true) $("#tfg2_mod_agttypeA").prop("checked", true);
            if ($("#tfop1_mod_agttypeD").prop("checked") == true) $("#tfg2_mod_agttypeD").prop("checked", true);
            break;
        case "FC3":
            //FC3form
            if (IsEmpty($("#tft3_class1").val())) {
                $("#tfg3_mod_class").val("N");
            } else {
                $("#tfg3_mod_class").val("Y");
            }
            break;
        case "FC4":
            break;
    }

    //*****案件內容
    switch ($("#tfy_Arcase").val()) {
        case "FC1": case "FC10": case "FC9": case "FCA": case "FCB":
            //出名代理人檢查(apcust_fc_re1)
            if (main.chkAgt("FC2_apnum", "ttg1_apclass", "ttg1_agt_no") == false) return false;
            if ($("#tfy_Arcase").val() == "FCA") {
                if ($("#FC1_add_agt_no").val() == "") {
                    alert("交辦申請事項變更(新增代理人)，請選擇新增代理人！");
                    settab("#tran");
                    $("#FC1_add_agt_no").focus();
                    return false;
                }
            }
            break;
        case "FC11": case "FC5": case "FC7": case "FCH":
            //出名代理人檢查(apcust_fc_re)
            if (main.chkAgt("FC2_apnum", "ttg1_apclass", "ttg11_agt_no") == false) return false;
            break;
        case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
            //出名代理人檢查(apcust_fc_re1)
            if (main.chkAgt("FC0_apnum", "ttg2_apclass", "ttg2_agt_no") == false) return false;
            break;
        case "FC21": case "FC6": case "FC8": case "FCI":
            //出名代理人檢查(apcust_fc_re1)
            if (main.chkAgt("FC0_apnum", "ttg2_apclass", "ttg21_agt_no") == false) return false;
            break;
        case "FC3":
            //出名代理人檢查(apcust)
            if (main.chkAgt("apnum", "apclass", "ttg3_agt_no") == false) return false;
            break;
        case "FC4":
            //出名代理人檢查(apcust)
            if (main.chkAgt("apnum", "apclass", "ttg4_agt_no") == false) return false;

            if ($("input[name=fr4_S_Mark]").eq(0).prop("checked") == true) {
                $("#tfzd_Pul").val("2");
                $("#tfzd_S_Mark").val("");
            } else if ($("input[name=fr4_S_Mark]").eq(0).prop("checked") == true) {
                $("#tfzd_Pul").val("2");
                $("#tfzd_S_Mark").val("S");
            }
            break;
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark,#tfy_case_stat").unlock();
    $("#tfgp_seq").val($("#tfzb_seq").val());
    $("#tfgp_seq1").val($("#tfzb_seq1").val());

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //變更一案多件控制
    switch ($("#tfy_Arcase").val()) {
        case "FC11": case "FC5": case "FC7": case "FCH":
            if (CInt($("#tot_num11").val()) <= 1) {
                alert("變更案件請輸入多筆!!!");
                settab("#tran");
                $("#tot_num11").focus();
                return false;
            }
            var tot_num = CInt($("#tot_num11").val());//共N件
            var ctrlcnt = 0;//有輸入值的件數
            for (var i = 1; i <= CInt($("#tot_num11").val()) ; i++) {
                if ($("#appl_namea_" + i).val() != "" && $("#dseqa_" + i).val() != "") {
                    ctrlcnt++;
                }
            }
            if (tot_num != ctrlcnt) {
                var answer = "變更件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
                if (answer) {
                    $("#tot_num11").val(ctrlcnt).triggerHandler("change");
                } else {
                    settab("#tran");
                    $("#tot_num11").focus();
                    return false;
                }
            }
            $("#nfy_tot_num").val($("#tot_num11").val());
            break;
        case "FC21": case "FC6": case "FC8": case "FCI":
            if (CInt($("#tot_num21").val()) <= 1) {
                alert("變更案件請輸入多筆!!!");
                settab("#tran");
                $("#tot_num21").focus();
                return false;
            }
            var tot_num = CInt($("#tot_num21").val());//共N件
            var ctrlcnt = 0;//有輸入值的件數
            for (var i = 1; i <= CInt($("#tot_num21").val()) ; i++) {
                if ($("#appl_nameb_" + i).val() != "" && $("#dseqb_" + i).val() != "") {
                    ctrlcnt++;
                }
            }
            if (tot_num != ctrlcnt) {
                var answer = "變更件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
                if (answer) {
                    $("#tot_num21").val(ctrlcnt).triggerHandler("change");
                } else {
                    settab("#tran");
                    $("#tot_num21").focus();
                    return false;
                }
            }
            $("#nfy_tot_num").val($("#tot_num21").val());
            break;
        default:
            $("#nfy_tot_num").val("1");
            break;
    }

    switch ($("#tfy_Arcase").val()) {
        case "FC11": case "FC5": case "FC7": case "FCH":
            for (var x = 1; x <= CInt($("#nfy_tot_num").val()) ; x++) {
                if ($("input[name='case_stat1a_" + x + "']:eq(1)").prop("checked") == true) {
                    if ($("#keydseqa_" + x).val() == "N") {
                        alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
                        settab("#tran");
                        $("#btndseq_oka_" + x).focus();
                        return false;
                    }
                }
            } break;
        case "FC21": case "FC6": case "FC8": case "FCI":
            for (var x = 1; x <= CInt($("#nfy_tot_num").val()) ; x++) {
                if ($("input[name='case_stat1b_" + x + "']:eq(1)").prop("checked") == true) {
                    if ($("#keydseqb_" + x).val() == "N") {
                        alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
                        settab("#tran");
                        $("#btndseq_okb_" + x).focus();
                        return false;
                    }
                }
            }
            break;
    }
    //附註檢查
    switch ($("#tfy_Arcase").val()) {
        case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
            if ($("#O_item21").val() == "" && $("input[name=O_item22]").prop("checked").length > 0) {
                if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
                    settab("#tran");
                    $("#O_item21").focus();
                    return false;
                }
            }
            break;
        case "FC21": case "FC6": case "FC8":
            if ($("#O_item211").val() == "" && $("input[name=O_item221]").prop("checked").length > 0) {
                if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
                    settab("#tran");
                    $("#O_item211").focus();
                    return false;
                }
            }
            break;
        case "FC3":
            if ($("#O_item31").val() == "" && $("input[name=O_item32]").prop("checked").length > 0) {
                if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
                    settab("#tran");
                    $("#O_item31").focus();
                    return false;
                }
            }
            break;
    }

    return true;
}

main.savechkA7 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //*****案件內容
    var errName = "", errName1 = "";
    if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
        errName = "授權起日";
        errName1 = "授權迄日";
    } else {
        errName = "終止日期";
    }
    if ($("#tfg1_term1").val() == "") {
        if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
			|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
		) {
            if ($("input[name='tfg1_mod_claim1']").eq(0).prop("checked") == true) {
                alert(errName + "不得為空白,請重新輸入!!");
                settab("#tran");
                $("#tfg1_term1").focus();
                return false;
            }
        } else {
            alert(errName + "不得為空白,請重新輸入!!");
            settab("#tran");
            $("#tfg1_term1").focus();
            return false;
        }
    }

    if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
        if ($("input[name='tfg1_mod_claim1']").eq(0).prop("checked") == true) {
            if ($("#tfg1_term2").val() == "") {
                alert(errName1 + "不得為空白,請重新輸入!!");
                settab("#tran");
                $("#tfg1_term2").focus();
                return false;
            }
        }
    }

    //點選無截止日種類之檢查
    if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
        if ($("input[name='tfg1_mod_claim1']").eq(1).prop("checked") == true) {
            if ($("#fl_term1").val() == "") {
                alert(errName + "不得為空白,請重新輸入!!");
                settab("#tran");
                $("#fl_term1").focus();
                return false;
            }
            $("#tfg1_term1").val($("#fl_term1").val());
        }
    }

    if ($("input[name=tfzd_Mark]").prop("checked").length == 0) {
        alert("請輸入申請人!!");
        settab("#tran");
        $("input[name='tfzd_Mark']").eq(0).focus();
        return false;
    }

    //***授權商品
    if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
        if ($("input[name=tfl1_mod_type]").prop("checked").length == 0) {
            alert("請選擇授權商品為全部授權或部份授權!!");
            settab("#tran");
            $("input[name='tfl1_mod_type']").eq(0).focus();
            return false;
        }
        if ($("#mod_count").val() != "" || $("#mod_dclass").val() != "") {
            $("#tfg1_mod_class").val("Y");
        } else {
            $("#tfg1_mod_class").val("N");
        }
    }

    //附註檢查
    if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
        if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }
    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //授權多件檢查
    if ($("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6") {
        var title_name = "";
        if ($("#tfy_Arcase").val().Left(3) == "FL5") { title_name = "授權"; } else { title_name = "被授權"; }
        if (CInt($("#tot_num21").val()) <= 1) {
            alert(title_name + "案件請輸入多筆!!!");
            settab("#tran");
            $("#tot_num21").focus();
            return false;
        }
        var tot_num = CInt($("#tot_num21").val());//共N件
        var ctrlcnt = 0;//有輸入值的件數
        for (var i = 1; i <= CInt($("#tot_num21").val()) ; i++) {
            if ($("#appl_nameb_" + i).val() != "" && $("#dseqb_" + i).val() != "") {
                ctrlcnt++;
            }
        }
        if (tot_num != ctrlcnt) {
            var answer = title_name + "件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
            if (answer) {
                $("#tot_num21").val(ctrlcnt).triggerHandler("change");
            } else {
                settab("#tran");
                $("#tot_num21").focus();
                return false;
            }
        }
        $("#nfy_tot_num").val($("#tot_num21").val());

        for (var x = 1; x <= CInt($("#nfy_tot_num").val()) ; x++) {
            if ($("input[name='case_stat1b_" + x + "']:eq(1)").prop("checked") == true) {
                if ($("#keydseqb_" + x).val() == "N") {
                    alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
                    settab("#tran");
                    $("#keydseqb_" + x).focus();
                    return false;
                }
            }
        }
    } else {
        $("#nfy_tot_num").val("1");
    }

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkA8 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;


    //附註檢查
    if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
        if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }

    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //移轉多件檢查
    var title_name = "";
    if ($("#tfy_Arcase").val().Left(3) == "FT2") {
        title_name = "移轉";

        if (CInt($("#tot_num21").val()) <= 1) {
            alert(title_name + "案件請輸入多筆!!!");
            settab("#tran");
            $("#tot_num21").focus();
            return false;
        }

        if ($("#tot_num21").val() != "") {
            var tot_num = CInt($("#tot_num21").val());//共N件
            var ctrlcnt = 0;//有輸入值的件數
            for (var i = 1; i <= CInt($("#tot_num21").val()) ; i++) {
                if ($("#appl_nameb_" + i).val() != "" && $("#dseqb_" + i).val() != "") {
                    ctrlcnt++;
                }
            }
            if (tot_num != ctrlcnt) {
                var answer = title_name + "件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
                if (answer) {
                    $("#tot_num21").val(ctrlcnt).triggerHandler("change");
                } else {
                    settab("#tran");
                    $("#tot_num21").focus();
                    return false;
                }
            }
        }

        $("#nfy_tot_num").val($("#tot_num21").val());

        for (var x = 1; x <= CInt($("#nfy_tot_num").val()) ; x++) {
            if ($("input[name='case_stat1b_" + x + "']:eq(1)").prop("checked") == true) {
                if ($("#keydseqb_" + x).val() == "N") {
                    alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
                    settab("#tran");
                    $("#btndseq_okb_" + x).focus();
                    return false;
                }
            }
        }
    } else {
        $("#nfy_tot_num").val("1");
    }

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //*****案件內容
    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkA9 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //*****案件內容
    if ($("#tfy_Arcase").val().Left(3) == "FP1") {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

        $("#tfg1_seq").val($("#tfzb_seq").val());
        $("#tfg1_seq1").val($("#tfzb_seq1").val());
    } else if ($("#tfy_Arcase").val().Left(3) == "FP2") {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

        $("#tfg2_seq").val($("#tfzb_seq").val());
        $("#tfg2_seq1").val($("#tfzb_seq1").val());
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();

    return true;
}

main.savechkAA = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //附註檢查
    if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
        if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //*****案件內容
    if ($("input[name=tfgd_mod_claim1]").eq(0).prop("checked") == true) {
        if (IsEmpty($("#tfn1_term1").val())) {
            alert("專用起日不得為空白，請重新輸入!!!");
            settab("#tran");
            $("#tfn1_term1").focus();
            return false;
        } else {
            $("#tfg3_term1").val($("#tfn1_term1").val());
        }
        if (IsEmpty($("#tfn1_term2").val())) {
            alert("專用迄日不得為空白，請重新輸入!!!");
            settab("#tran");
            $("#tfn1_term2").focus();
            return false;
        } else {
            $("#tfg3_term2").val($("#tfn1_term2").val());
        }
    } else if ($("input[name=tfgd_mod_claim1]").eq(1).prop("checked") == true) {
        if (IsEmpty($("#tfn2_term1").val())) {
            alert("申請日不得為空白，請重新輸入!!!");
            settab("#tran");
            $("#tfn2_term1").focus();
            return false;
        } else {
            $("#tfg3_term1").val($("#tfn2_term1").val());
        }
    }

    if ($("input[name=tfgd_tran_Mark]").prop("checked").length == 0) {
        alert("請輸入證明書種類!!");
        settab("#tran");
        $("input[name=tfgd_tran_Mark]").eq(0).focus();
        return false;
    }

    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfgd_agt_no1") == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfgd_seq").val($("#tfzb_seq").val());
    $("#tfgd_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkAB = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //附註檢查
    if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
        if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }

    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //*****案件內容
    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkAC = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    //出名代理人檢查
    if (main.chkAgt("apnum", "apclass", "tfzd_agt_no") == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkB = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //****備註日期
    switch ($("#tfy_Arcase").val().Left(3)) {
        case "DR1":
            $("#tfzd_appl_name").val($("#fr1_appl_name").val());
            $("#tfzd_issue_no").val($("#fr1_issue_no").val());
            //大陸案請款註記檢查.請款註記:大陸進口案
            if ($("#tfp1_seq1").val() == "M" && $("#tfy_ar_mark").val() != "X") {
                alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
                settab("#case");
                $("#tfy_ar_mark").focus();
                return false;
            } else if ($("#tfp1_seq1").val() != "M" && $("#tfy_ar_mark").val() == "X") {
                alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
                settab("#tran");
                $("#tfp1_seq1").focus();
                return false;
            }
            if ($("#R_O_item1").val() != "" || $("#R_O_item2").val() != "" || $("#R_O_item3").val() != "") {
                $("#tfz1_other_item").val($("#R_O_item1").val() + ";" + $("#R_O_item2").val() + ";" + $("#R_O_item3").val());
            }
            if ($("#ttg11_mod_pul_new_no").val() != "" || $("#ttg11_mod_pul_ncname1").val() != "") {
                if ($("input[name='ttg11_mod_pul_mod_type']:checked").length == 0) {
                    alert("第" + $("#ttg11_mod_pul_new_no").val() + "號「" + $("#ttg11_mod_pul_ncname1").val() + "」有輸入資料，請選擇商標或標章，如不選擇，請將輸入資料清空！");
                    settab("#tran");
                    $("input[name='ttg11_mod_pul_mod_type']:eq(0)").focus();
                    return false;
                }
            }
            if ($("#ttg13_mod_pul_new_no").val() != "" || $("#ttg13_mod_pul_mod_dclass").val() != "") {
                if ($("#ttg13_mod_pul_mod_type").prop("checked") == false) {
                    alert("指定使用於商標法施行細則第" + $("#ttg13_mod_pul_new_no").val() + "條第" + $("#ttg13_mod_pul_mod_dclass").val() + "類商品／服務之註冊應予廢止有輸入資料，請勾選，如不勾選，請將輸入資料清空！");
                    settab("#tran");
                    $("#ttg13_mod_pul_mod_type").focus();
                    return false;
                }
            }
            if ($("#ttg14_mod_pul_new_no").val() != "" || $("#ttg14_mod_pul_mod_dclass").val() != "" || $("#ttg14_mod_pul_ncname1").val() != "") {
                if ($("#ttg14_mod_pul_mod_type").prop("checked") == false) {
                    alert("指定使用於商標法施行細則第" + $("#ttg14_mod_pul_new_no").val() + "條第" + $("#ttg14_mod_pul_mod_dclass").val() + "類" + $("#ttg14_mod_pul_ncname1").val() + "商品／服務之商標權應予廢止有輸入資料，請勾選，如不勾選，請將輸入資料清空！");
                    settab("#tran");
                    $("#ttg14_mod_pul_mod_type").focus();
                    return false;
                }
            }
            //出名代理人檢查
            if (main.chkAgt("apnum", "apclass", "tfp1_agt_no") == false) return false;

            //2012/10/3增加廢止商標包含部份，因2012/7/1新申請書修改
            $("#tfzd_Cappl_name").val($("input[name='R_cappl_name']:checked").val() || "");
            $("#tfzd_eappl_name").val($("input[name='R_eappl_name']:checked").val() || "");
            $("#tfzd_jappl_name").val($("input[name='R_jappl_name']:checked").val() || "");
            $("#tfzd_Draw").val($("input[name='R_draw']:checked").val() || "");
            $("#tfzd_zappl_name1").val($("input[name='R_zappl_name1']:checked").val() || "");
            $("#tfzd_remark3").val($("input[name='R_remark3']:checked").val() || "");

            $("#draw_file").val($("#tfp1_draw_file").val());
            $("input[name='fr1_class_type']:checked").triggerHandler("click");
            $("#tfy_case_stat").val($("#tfp1_case_stat").val());
            if ($("#tfy_case_stat").val() == "NN") {
                $("#tfzb_seq").val($("#tfp1_seq").val());
                $("#tfzb_seq1").val($("#tfp1_seq1").val());
            } else if ($("#tfy_case_stat").val() == "SN") {
                $("#tfzb_seq").val($("#tfp1_New_Ass_seq").val());
                $("#tfzb_seq1").val($("#tfp1_New_Ass_seq1").val());
                if (IsEmpty($("#tfp1_New_Ass_seq").val())) {
                    alert("案件編號不得為空白，請重新輸入");
                    settab("#tran");
                    $("#tfp1_New_Ass_seq").focus();
                    return false;
                }
                if (IsEmpty($("#tfp1_New_Ass_seq1").val())) {
                    alert("案件編號副碼不得為空白，請重新輸入");
                    settab("#tran");
                    $("#tfp1_New_Ass_seq1").focus();
                    return false;
                }
            }
            break;
        case "DO1":
            $("#tfzd_appl_name").val($("#fr2_appl_name").val());
            $("#tfzd_issue_no").val($("#fr2_issue_no").val());
            if ($("#tfp2_seq1").val() == "M" && $("#tfy_ar_mark").val() != "X") {
                alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
                settab("#case");
                $("#tfy_ar_mark").focus();
                return false;
            } else if ($("#tfp2_seq1").val() != "M" && $("#tfy_ar_mark").val() == "X") {
                alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
                settab("#tran");
                $("#tfp2_seq1").focus();
                return false;
            }
            if ($("#O_O_item1").val() != "" || $("#O_O_item2").val() != "" || $("#O_O_item3").val() != "") {
                $("#tfz2_other_item").val($("#O_O_item1").val() + ";" + $("#O_O_item2").val() + ";" + $("#O_O_item3").val());
            }
            if ($("#ttg21_mod_pul_new_no").val() != "" || $("#ttg21_mod_pul_ncname1").val() != "") {
                if ($("input[name='ttg21_mod_pul_mod_type']:checked").length == 0) {
                    alert("第" + $("#ttg21_mod_pul_new_no").val() + "號「" + $("#ttg21_mod_pul_ncname1").val() + "」有輸入資料，請選擇商標或標章，如不選擇，請將輸入資料清空！");
                    settab("#tran");
                    $("input[name='ttg21_mod_pul_mod_type']:eq(0)").focus();
                    return false;
                }
            }
            if ($("#ttg23_mod_pul_new_no").val() != "" || $("#ttg23_mod_pul_mod_dclass").val() != "") {
                if ($("#ttg13_mod_pul_mod_type").prop("checked") == false) {
                    alert("指定使用於商標法施行細則第" + $("#ttg23_mod_pul_new_no").val() + "條第" + $("#ttg23_mod_pul_mod_dclass").val() + "類商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！");
                    settab("#tran");
                    $("#ttg23_mod_pul_mod_type").focus();
                    return false;
                }
            }
            if ($("#ttg24_mod_pul_new_no").val() != "" || $("#ttg24_mod_pul_mod_dclass").val() != "" || $("#ttg24_mod_pul_ncname1").val() != "") {
                if ($("#ttg24_mod_pul_mod_type").prop("checked") == false) {
                    alert("指定使用於商標法施行細則第" + $("#ttg24_mod_pul_new_no").val() + "條第" + $("#ttg24_mod_pul_mod_dclass").val() + "類" + $("#ttg24_mod_pul_ncname1").val() + "商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！");
                    settab("#tran");
                    $("#ttg24_mod_pul_mod_type").focus();
                    return false;
                }
            }
            //出名代理人檢查
            if (main.chkAgt("apnum", "apclass", "tfp2_agt_no") == false) return false;
            $("#tfzd_Cappl_name").val($("input[name='O_cappl_name']:checked").val() || "");
            $("#tfzd_eappl_name").val($("input[name='O_eappl_name']:checked").val() || "");
            $("#tfzd_jappl_name").val($("input[name='O_jappl_name']:checked").val() || "");
            $("#tfzd_Draw").val($("input[name='O_draw']:checked").val() || "");
            $("#tfzd_zappl_name1").val($("input[name='O_zappl_name1']:checked").val() || "");
            $("#tfzd_remark3").val($("input[name='O_remark3']:checked").val() || "");

            $("#draw_file").val($("#tfp2_draw_file").val());
            $("input[name='fr2_class_type']:checked").triggerHandler("click");
            $("#tfy_case_stat").val($("#tfp2_case_stat").val());
            if ($("#tfy_case_stat").val() == "NN") {
                $("#tfzb_seq").val($("#tfp2_seq").val());
                $("#tfzb_seq1").val($("#tfp2_seq1").val());
            } else if ($("#tfy_case_stat").val() == "SN") {
                $("#tfzb_seq").val($("#tfp2_New_Ass_seq").val());
                $("#tfzb_seq1").val($("#tfp2_New_Ass_seq1").val());
                if (IsEmpty($("#tfp2_New_Ass_seq").val())) {
                    alert("案件編號不得為空白，請重新輸入");
                    settab("#tran");
                    $("#tfp2_New_Ass_seq").focus();
                    return false;
                }
                if (IsEmpty($("#tfp2_New_Ass_seq1").val())) {
                    alert("案件編號副碼不得為空白，請重新輸入");
                    settab("#tran");
                    $("#tfp2_New_Ass_seq1").focus();
                    return false;
                }
            }
            break;
        case "DI1":
            $("#tfzd_appl_name").val($("#fr3_appl_name").val());
            $("#tfzd_issue_no").val($("#fr3_issue_no").val());
            //大陸案請款註記檢查.請款註記:大陸進口案
            if ($("#tfp3_seq1").val() == "M" && $("#tfy_ar_mark").val() != "X") {
                alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
                settab("#case");
                $("#tfy_ar_mark").focus();
                return false;
            } else if ($("#tfp3_seq1").val() != "M" && $("#tfy_ar_mark").val() == "X") {
                alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
                settab("#tran");
                $("#tfp3_seq1").focus();
                return false;
            }
            if ($("#I_O_item1").val() != "" || $("#I_O_item2").val() != "" || $("#I_O_item3").val() != "") {
                $("#tfz3_other_item").val($("#I_O_item1").val() + ";" + $("#I_O_item2").val() + ";" + $("#I_O_item3").val());
            }
            if ($("#ttg31_mod_pul_new_no").val() != "" || $("#ttg31_mod_pul_ncname1").val() != "") {
                if ($("input[name='ttg31_mod_pul_mod_type']:checked").length == 0) {
                    alert("第" + $("#ttg31_mod_pul_new_no").val() + "號「" + $("#ttg31_mod_pul_ncname1").val() + "」有輸入資料，請選擇商標或標章，如不選擇，請將輸入資料清空！");
                    settab("#tran");
                    $("input[name='ttg31_mod_pul_mod_type']:eq(0)").focus();
                    return false;
                }
            }
            if ($("#ttg33_mod_pul_new_no").val() != "" || $("#ttg33_mod_pul_mod_dclass").val() != "") {
                if ($("#ttg33_mod_pul_mod_type").prop("checked") == false) {
                    alert("指定使用於商標法施行細則第" + $("#ttg33_mod_pul_new_no").val() + "條第" + $("#ttg33_mod_pul_mod_dclass").val() + "類商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！");
                    settab("#tran");
                    $("#ttg33_mod_pul_mod_type").focus();
                    return false;
                }
            }

            if ($("#ttg34_mod_pul_new_no").val() != "" || $("#ttg34_mod_pul_mod_dclass").val() != "" || $("#ttg34_mod_pul_ncname1").val() != "") {
                if ($("#ttg34_mod_pul_mod_type").prop("checked") == false) {
                    alert("指定使用於商標法施行細則第" + $("#ttg34_mod_pul_new_no").val() + "條第" + $("#ttg34_mod_pul_mod_dclass").val() + "類" + $("#ttg34_mod_pul_ncname1").val() + "商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！");
                    settab("#tran");
                    $("#ttg34_mod_pul_mod_type").focus();
                    return false;
                }
            }
            //出名代理人檢查
            if (main.chkAgt("apnum", "apclass", "tfp3_agt_no") == false) return false;

            //2012/10/3增加廢止商標包含部份，因2012/7/1新申請書修改
            $("#tfzd_Cappl_name").val($("input[name='I_cappl_name']:checked").val() || "");
            $("#tfzd_eappl_name").val($("input[name='I_eappl_name']:checked").val() || "");
            $("#tfzd_jappl_name").val($("input[name='I_jappl_name']:checked").val() || "");
            $("#tfzd_Draw").val($("input[name='I_draw']:checked").val() || "");
            $("#tfzd_zappl_name1").val($("input[name='I_zappl_name1']:checked").val() || "");
            $("#tfzd_remark3").val($("input[name='I_remark3']:checked").val() || "");

            if ($("input[name='I_item1']:checked").length > 0) {
                //2013/1/24因應商標法修正改為多選
                var pother_item1 = "";
                if ($("input[name='I_item1']:eq(0)").prop("checked") == true) {
                    pother_item1 += (pother_item1 != "" ? "|" : "") + $("input[name='I_item1']:eq(0)").val();
                }
                if ($("input[name='I_item1']:eq(1)").prop("checked") == true) {
                    pother_item1 += (pother_item1 != "" ? "|" : "") + $("input[name='I_item1']:eq(1)").val();
                }
                if ($("input[name='I_item1']:eq(2)").prop("checked") == true) {
                    pother_item1 += (pother_item1 != "" ? "|" : "") + $("input[name='I_item1']:eq(2)").val();
                }
                if ($("input[name='I_item1']:eq(0)").prop("checked") == true || $("input[name='I_item1']:eq(1)").prop("checked") == true) {
                    pother_item1 += ";" + $("#I_item2").val();
                    if ($("input[name='I_item1']:eq(1)").prop("checked") == true) {
                        pother_item1 += "|" + $("#I_item2t").val();
                    }
                } else if ($("input[name='I_item1']:eq(2)").prop("checked") == true) {
                    pother_item1 += ";" + $("#I_item2t").val();
                }
            } else {
                $("#tfz3_other_item1").val("");
            }

            $("#draw_file").val($("#tfp3_draw_file").val());
            $("input[name='fr3_class_type']:checked").triggerHandler("click");
            $("#tfy_case_stat").val($("#tfp3_case_stat").val());
            if ($("#tfy_case_stat").val() == "NN") {
                $("#tfzb_seq").val($("#tfp3_seq").val());
                $("#tfzb_seq1").val($("#tfp3_seq1").val());
            } else if ($("#tfy_case_stat").val() == "SN") {
                $("#tfzb_seq").val($("#tfp3_New_Ass_seq").val());
                $("#tfzb_seq1").val($("#tfp3_New_Ass_seq1").val());
                if (IsEmpty($("#tfp3_New_Ass_seq").val())) {
                    alert("案件編號不得為空白，請重新輸入");
                    settab("#tran");
                    $("#tfp3_New_Ass_seq").focus();
                    return false;
                }
                if (IsEmpty($("#tfp3_New_Ass_seq1").val())) {
                    alert("案件編號副碼不得為空白，請重新輸入");
                    settab("#tran");
                    $("#tfp3_New_Ass_seq1").focus();
                    return false;
                }
            }
            break;
        default:
            //新/舊案號
            if (main.chkNewOld() == false) return false;
            //大陸案請款註記檢查
            if ($("#tfzb_seq1").val() == "M" && $("#tfy_Ar_mark").val() != "X") {
                alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
                settab("#case");
                $("#tfy_Ar_mark").focus();
                return false;
            } else if ($("#tfzb_seq1").val() != "M" && $("#tfy_Ar_mark").val() == "X") {
                alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
                settab("#tran");
                if ($("#tfy_case_stat").val() == "NN") {
                    $("#New_seq1").focus();
                } else if ($("#tfy_case_stat").val() == "OO") {
                    $("#old_seq1").focus();
                }
                return false;
            }
            if ($("#tfy_Arcase").val().Left(3) != "DE1" && $("#tfy_Arcase").val().Left(3) != "DE2") {
                //出名代理人檢查
                if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;
            }
            break;
    }

    //案件內容
    if ($("#tfy_Arcase").val().Left(3) == "DE1") {
        if ($("input[name='fr4_remark3']:checked").length = 0) {
            alert("請輸入申請舉行聽證之案件種類!!");
            settab("#tran");
            $("input[name='fr4_remark3']:eq(0)").focus();
            return false
        } else {
            $("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");

        }

        if ($("input[name='fr4_Mark']:checked").length = 0) {
            alert("請輸入申請人種類!!");
            settab("#tran");
            $("input[name='fr4_Mark']:eq(0)").focus();
            return false
        } else {
            $("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
        }

        if ($("input[name=fr4_tran_mark]").prop("checked").length == 0) {
            alert("請輸入對照當事人種類!!");
            settab("#tran");
            $("input[name='fr4_tran_mark']").eq(0).focus();
            return false;
        }

        if (CInt($("#DE1_apnum").val()) == 0) {
            alert("請輸入對照當事人資料！");
            settab("#tran");
            return false;
        }
        for (var k = 1; k <= CInt($("#DE1_apnum").val()) ; k++) {
            if ($("#tfr4_ncname1_" + k).val() == "") {
                alert("請輸入對照當事人名稱!!");
                settab("#tran");
                return false;
            }
        }
        if ($("#fr4_tran_remark1").val() == "") {
            alert("請輸入應舉行聽證之理由!!");
            settab("#tran");
            $("#fr4_tran_remark1").focus();
            return false;
        }
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
    } else if ($("#tfy_Arcase").val().Left(3) == "DE2") {
        if ($("input[name=fr4_remark3]").prop("checked").length == 0) {
            alert("請輸入申請舉行聽證之案件種類!!");
            settab("#tran");
            $("input[name='fr4_remark3']").eq(0).focus();
            return false;
        } else {
            $("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
        }

        if ($("input[name=fr4_Mark]").prop("checked").length == 0) {
            alert("請輸入申請人種類!!");
            settab("#tran");
            $("input[name='fr4_Mark']").eq(0).focus();
            return false;
        } else {
            $("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
        }

        if ($("#fr4_tran_remark1").val() == "") {
            alert("請輸入新事證及陳述意見書!!");
            settab("#tran");
            $("#fr4_tran_remark1").focus();
            return false;
        }
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //2010/10/4異議、評定及廢止增加記錄類別，不用檢查類別及其商品資料，但需檢查類別數與輸入費用類數是否相同
    if ($("#tfy_Arcase").val().Left(3) == "DO1" || $("#tfy_Arcase").val().Left(3) == "DI1" || $("#tfy_Arcase").val().Left(3) == "DR1") {
        //2010/10/8類別檢查，至少輸入一類
        var sclass_count = 1;//收費標準類別數，基準值=1
        var pname = "";
        switch ($("#tfy_Arcase").val().Left(3)) {
            case "DR1":
                pname = "fr1_class";
                for (var r = 1; r <= CInt($("#TaCount").val()) ; r++) {
                    if ($("#nfyi_item_Arcase_" + r).val() == "DR1B") {
                        sclass_count += CInt($("#nfyi_item_count_" + r).val());
                        break;
                    }
                }
                break;
            case "DO1":
                pname = "fr2_class";
                for (var r = 1; r <= CInt($("#TaCount").val()) ; r++) {
                    if ($("#nfyi_item_Arcase_" + r).val() == "DO1B") {
                        sclass_count += CInt($("#nfyi_item_count_" + r).val());
                        break;
                    }
                }
                break;
            case "DI1":
                pname = "fr3_class";
                for (var r = 1; r <= CInt($("#TaCount").val()) ; r++) {
                    if ($("#nfyi_item_Arcase_" + r).val() == "DI1B") {
                        sclass_count += CInt($("#nfyi_item_count_" + r).val());
                        break;
                    }
                }
                break;
        }
        if ($("#" + pname).val() == "") {
            alert("請輸入類別資料！");
            settab("#tran");
            $("#" + pname).focus();
            return false;
        }
        var pclass_count = $("#" + pname + "_count").val();
        if (CInt(pclass_count) != sclass_count) {
            alert("收費提列類別數(共" + sclass_count + "類)與交辦內容類別數(共" + pclass_count + "類)不同，請檢查！");
            settab("#case");
            return false;
        }
    } else {
        //主檔商品類別檢查
        if (main.chkGood() == false) return false;
    }

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    return true;
}

main.savechkZZ = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }

    //商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());

    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

    //*****案件內容
    if ($("#tfy_Arcase").val().Left(3) == "FOB") {
        if ($("#tfg1_other_item").val() == "") {
            alert("影印內容沒有勾選，請輸入!!");
            settab("#tran");
            $("#ttz1_P1").focus();
            return false;
        }
        $("#tfzd_mark").val($("input[name='fr_Mark']:checked").val() || "");
    }
    if ($("#tfy_Arcase").val().Left(3) == "AD7") {
        if ($("input[name=fr4_remark3]").prop("checked").length == 0) {
            alert("請輸入申請舉行聽證之案件種類!!");
            settab("#tran");
            $("input[name='fr4_remark3']").eq(0).focus();
            return false;
        } else {
            $("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
        }

        if ($("input[name=fr4_Mark]").prop("checked").length == 0) {
            alert("請輸入申請人種類!!");
            settab("#tran");
            $("input[name='fr4_Mark']").eq(0).focus();
            return false;
        } else {
            $("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
        }

        if ($("input[name=fr4_tran_mark]").prop("checked").length == 0) {
            alert("請輸入對照當事人種類!!");
            settab("#tran");
            $("input[name='fr4_tran_mark']").eq(0).focus();
            return false;
        }

        if (CInt($("#DE1_apnum").val()) == 0) {
            alert("請輸入對照當事人資料！");
            settab("#tran");
            return false;
        }
        for (var k = 1; k <= CInt($("#DE1_apnum").val()) ; k++) {
            if ($("#tfr4_ncname1_" + k).val() == "") {
                alert("請輸入對照當事人名稱!!");
                settab("#tran");
                return false;
            }
        }
        if ($("#fr4_tran_remark1").val() == "") {
            alert("請輸入應舉行聽證之理由!!");
            settab("#tran");
            $("#fr4_tran_remark1").focus();
            return false;
        }
    } else if ($("#tfy_Arcase").val().Left(3) == "AD8") {
        if ($("input[name=fr4_remark3]").prop("checked").length == 0) {
            alert("請輸入申請舉行聽證之案件種類!!");
            settab("#tran");
            $("input[name='fr4_remark3']").eq(0).focus();
            return false;
        } else {
            $("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
        }

        if ($("input[name=fr4_Mark]").prop("checked").length == 0) {
            alert("請輸入申請人種類!!");
            settab("#tran");
            $("input[name='fr4_Mark']").eq(0).focus();
            return false;
        } else {
            $("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
        }

        if ($("#fr4_tran_remark1").val() == "") {
            alert("請輸入新事證及陳述意見書!!");
            settab("#tran");
            $("#fr4_tran_remark1").focus();
            return false;
        }
    }
    //申請退費檢查
    if ($("#tfy_Arcase").val().Left(3) == "FOF") {
        if ($("#tfzf_other_item").val() == "") {
            alert("請輸入國庫支票抬頭名稱！！");
            settab("#tran");
            $("#tfzf_other_item").focus();
            return false;
        }
        if ($("#tfzf_debit_money").val() == "") {
            alert("請輸入退費金額！！");
            settab("#tran");
            $("#tfzf_debit_money").focus();
            return false;
        } else {
            if (IsNumeric($("#tfzf_debit_money").val()) == false) {
                alert("退費金額必須為數值，請重新輸入！！");
                settab("#tran");
                $("#tfzf_debit_money").focus();
                return false;
            }
        }
        if ($("#tfzf_other_item1").val() == "") {
            alert("請輸入規費收據號碼！！");
            settab("#tran");
            $("#tfzf_other_item1").focus();
            return false;
        }
        if ($("#tfzf_other_item2").val() == "") {
            //20190613增加 權限C可不輸入退費函字號
            if ((main.right & 256) != 0) {
                alert("請輸入本局通知退費函字號！！");
                settab("#tran");
                $("input[name='ttzf_F1']:eq(0)").focus();
                return false;
            }
        } else {
            if ($("input[name='ttzf_F1']:eq(0)").prop("checked") == true) {
                if ($("#F1_yy").val() == "" || $("#F1_word").val() == "" || $("#F1_no").val() == "") {
                    alert("請輸入本局通知退費函字號！！");
                    settab("#tran");
                    $("#F1_yy").focus();
                    return false;
                }
            }
            if ($("input[name='ttzf_F1']:eq(1)").prop("checked") == true) {
                if ($("#F2_yy").val() == "" || $("#F2_word").val() == "" || $("#F2_no").val() == "") {
                    alert("請輸入本局通知退費函字號！！");
                    settab("#tran");
                    $("#F2_yy").focus();
                    return false;
                }
            }
        }
        $("#tfzd_mark").val($("input[name='frf_mark']:checked").val() || "");
    }
    //申請補送文件檢查
    if ($("#tfy_Arcase").val().Left(3) == "FB7") {
        if ($("#tfb7_other_item").val() == "") {
            alert("請勾選補送文件！");
            return false;
        }
    }

    //申請撤回申請檢查
    if ($("#tfy_Arcase").val().Left(3) == "FW1") {
        if ($("#tfw1_mod_claim1").prop("checked") == false) {
            alert("請勾選「本申請案自請撤回」");
            return false;
        }
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

    if ($("#tfy_Arcase").val().Left(3) == "FOB") {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfg2_agt_no1") == false) return false;
    } else if ($("#tfy_Arcase").val().Left(3) == "AD7" || $("#tfy_Arcase").val().Left(3) == "AD8") {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
    } else if ($("#tfy_Arcase").val().Left(3) == "FOF") {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfzf_agt_no1") == false) return false;
    } else if ($("#tfy_Arcase").val().Left(3) == "FB7") {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfb7_agt_no1") == false) return false;
    } else {
        //出名代理人檢查
        if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;
    }

    return true;
}