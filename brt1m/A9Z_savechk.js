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
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢杳"); return false; }

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    if (IsEmpty($("#tfy_case_stat").val())) {
        alert("請輸入案件種類!!");
        settab("#dmt");
        $("#tfy_case_stat").focus();
        return false;
    }
    //商標名稱檢查
    if ($("#tfy_case_stat").val() == "NN" || $("#tfy_case_stat").val() == "SN") {
        if ($("#tfzd_appl_name").val() == "") {
            alert("商標名稱不可空白！");
            settab("#dmt");
            $("#tfzd_appl_name").focus();
            return false;
        }
        //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
        if (check_CustWatch("appl_name", $("#tfzd_appl_name").val()) == true) {
            settab("#dmt");
            $("#tfzd_appl_name").focus();
            return false;
        }
    }

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    //出名代理人檢查
    var apclass_flag = "N";
    var tran_agt_no = "";//交辦畫面的代理人欄位名
    if (main.ar_form == "A3") {//註冊費
        tran_agt_no = "tfg1_agt_no1";
    } else if (main.ar_form == "A4") {//延展
        tran_agt_no = "tfzd_agt_no";
    }

    for (var capnum = 1; capnum <= CInt($("#apnum").val()) ; capnum++) {
        if ($("#apclass_" + capnum).val().Left(1) == "C") {
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

    //*****主檔商品類別檢查
    //2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
    if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
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
    }
    $("#ctrlcount1").val(inputCount == 0 ? "" : inputCount);
    if (CInt($("#tfzr_class_count").val()) != CInt($("#num1").val())) {
        var answer = "指定使用商品類別項目(共 " + CInt($("#tfzr_class_count").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num1").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num1").val()) + " 類？";
        if (answer) {
            $("#tfzr_class_count").val($("#num1").val());
        } else {
            settab("#tran");
            $("#tfzr_class_count").focus();
            return false;
        }
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

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

    ////////////////////交辦專用
    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val());
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val());
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());
    $("#tfzd_end_code").val($("#tfzy_end_code").val());

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());
    $("#tfzd_agt_no").val($("#tfg1_agt_no1").val());

    return true;
}

main.savechkA4 = function () {
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢杳"); return false; }

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    if (IsEmpty($("#tfy_case_stat").val())) {
        alert("請輸入案件種類!!");
        settab("#dmt");
        $("#tfy_case_stat").focus();
        return false;
    }
    //商標名稱檢查
    if ($("#tfy_case_stat").val() == "NN" || $("#tfy_case_stat").val() == "SN") {
        if ($("#tfzd_appl_name").val() == "") {
            alert("商標名稱不可空白！");
            settab("#dmt");
            $("#tfzd_appl_name").focus();
            return false;
        }
        //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
        if (check_CustWatch("appl_name", $("#tfzd_appl_name").val()) == true) {
            settab("#dmt");
            $("#tfzd_appl_name").focus();
            return false;
        }
    }

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    //出名代理人檢查
    var apclass_flag = "N";
    var tran_agt_no = "";//交辦畫面的代理人欄位名
    if (main.ar_form == "A3") {//註冊費
        tran_agt_no = "tfg1_agt_no1";
    } else if (main.ar_form == "A4") {//延展
        tran_agt_no = "tfzd_agt_no";
    }

    for (var capnum = 1; capnum <= CInt($("#apnum").val()) ; capnum++) {
        if ($("#apclass_" + capnum).val().Left(1) == "C") {
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

    //*****主檔商品類別檢查
    //2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
    if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
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
    }
    $("#ctrlcount1").val(inputCount == 0 ? "" : inputCount);
    if (CInt($("#tfzr_class_count").val()) != CInt($("#num1").val())) {
        var answer = "指定使用商品類別項目(共 " + CInt($("#tfzr_class_count").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num1").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num1").val()) + " 類？";
        if (answer) {
            $("#tfzr_class_count").val($("#num1").val());
        } else {
            settab("#tran");
            $("#tfzr_class_count").focus();
            return false;
        }
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //****請款註記	
    if ($("#tfzb_seq1").val() == "M") {
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

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfgp_seq").val($("#tfzb_seq").val());
    $("#tfgp_seq1").val($("#tfzb_seq1").val());
    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val());
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val());
    $("#tfzd_Mark").val($("input[name='tfzy_mark']:checked").val());
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());
    $("#tfzd_end_code").val($("#tfzy_end_code").val());

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
            //檢查指定類別有無重覆
            var objClass = {};
            for (var r = 1; r <= CInt($("#num1").val()) ; r++) {
                var lineTa = $("#class2_" + r).val();
                if (lineTa != "" && objClass[lineTa]) {
                    alert("商品類別重覆,請重新輸入!!!");
                    $("#class2_" + r).focus();
                    return false;
                } else {
                    objClass[lineTa] = { flag: true, idx: r };
                }
            }
            var inputCount = 0;
            for (var j = 1; j <= CInt($("#num2").val()) ; j++) {
                if ($("#good_name1_" + j).val() != "" && $("#class2_" + j).val() == "") {
                    //有輸入商品名稱,但沒輸入類別
                    alert("請輸入類別!");
                    settab("#tran");
                    $("#class2_" + j).focus();
                    return false;
                }
                if (br_form.checkclass(j) == false) {//檢查類別範圍0~45
                    $("#class2_" + j).focus();
                    return false;
                }
                if ($("#class2_" + j).val() != "") {
                    inputCount++;//實際有輸入才要+
                }
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
    var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_pul", "mod_oth", "mod_oth1", "mod_oth2", "mod_dmt"];
    for (var m in arr_mod) {
        if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
            $("#tfgp_" + arr_mod[m]).val("Y");
        } else {
            $("#tfgp_" + arr_mod[m]).val("N");
        }

    }
    if ($("#tfzr_mod_agt").prop("checked") == true) {
        if ($("input[name=tfzr_mod_agttype]").prop("checked").length == 0) {
            $("#tfgp_mod_agttype").val("N");
        } else {
            $("#tfgp_mod_agttype").val($("input[name=tfzr_mod_agttype]:checked").val());
        }
    }
    //附註檢查
    if($("#O_item1").val()==""&&$("input[name=O_item2]").prop("checked").length>0){
        if(confirm("附註資料中日期未輸入，確定存檔?")==false){
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }

    //20161006增加備註檢查(因應電子送件修改備註.2欄都可存檔)
    if($("#O_item1").val()!=""&&$("input[name=O_item2]").prop("checked").length>0&&$("input[name=O_item]").eq(0).prop("checked")==false){
        alert("備註項目(1)未勾選，請檢查");
        return false;
    }
    if($("#O_item1").val()!=""&&$("input[name=O_item2]").prop("checked").length>0&&$("input[name=O_item]").eq(1).prop("checked")==false){
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
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢杳"); return false; }

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    if (IsEmpty($("#tfy_case_stat").val())) {
        alert("請輸入案件種類!!");
        settab("#dmt");
        $("#tfy_case_stat").focus();
        return false;
    }
    //商標名稱檢查
    if ($("#tfy_case_stat").val() == "NN" || $("#tfy_case_stat").val() == "SN") {
        if ($("#tfzd_appl_name").val() == "") {
            alert("商標名稱不可空白！");
            settab("#dmt");
            $("#tfzd_appl_name").focus();
            return false;
        }
        //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
        if (check_CustWatch("appl_name", $("#tfzd_appl_name").val()) == true) {
            settab("#dmt");
            $("#tfzd_appl_name").focus();
            return false;
        }
    }

    //新/舊案號
    if (main.chkNewOld() == false) return false;

    //出名代理人檢查
    var apclass_flag = "N";
    var tran_agt_no = "";//交辦畫面的代理人欄位名
    if (main.ar_form == "A3") {//註冊費
        tran_agt_no = "tfg1_agt_no1";
    } else if (main.ar_form == "A4") {//延展
        tran_agt_no = "tfzd_agt_no";
    }

    for (var capnum = 1; capnum <= CInt($("#apnum").val()) ; capnum++) {
        if ($("#apclass_" + capnum).val().Left(1) == "C") {
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

    //*****主檔商品類別檢查
    //2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
    if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
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
    }
    $("#ctrlcount1").val(inputCount == 0 ? "" : inputCount);
    if (CInt($("#tfzr_class_count").val()) != CInt($("#num1").val())) {
        var answer = "指定使用商品類別項目(共 " + CInt($("#tfzr_class_count").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num1").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num1").val()) + " 類？";
        if (answer) {
            $("#tfzr_class_count").val($("#num1").val());
        } else {
            settab("#tran");
            $("#tfzr_class_count").focus();
            return false;
        }
    }

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //****請款註記	
    if ($("#tfzb_seq1").val() == "M") {
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

    //註冊號數
    if (IsEmpty($("#tfzd_issue_no").val())) {
        alert("註冊號數不得為空白 ，日期格式是否正確!!");
        settab("#tran");
        $("#tfzd_issue_no").focus();
        return false;
    }

    $("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfgp_seq").val($("#tfzb_seq").val());
    $("#tfgp_seq1").val($("#tfzb_seq1").val());
    $("#tfzd_color").val($("input[name='tfzy_color']:checked").val());
    $("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val());
    $("#tfzd_Mark").val($("input[name='tfzy_mark']:checked").val());
    $("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());
    $("#tfzd_end_code").val($("#tfzy_end_code").val());

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
            //檢查指定類別有無重覆
            var objClass = {};
            for (var r = 1; r <= CInt($("#num1").val()) ; r++) {
                var lineTa = $("#class2_" + r).val();
                if (lineTa != "" && objClass[lineTa]) {
                    alert("商品類別重覆,請重新輸入!!!");
                    $("#class2_" + r).focus();
                    return false;
                } else {
                    objClass[lineTa] = { flag: true, idx: r };
                }
            }
            var inputCount = 0;
            for (var j = 1; j <= CInt($("#num2").val()) ; j++) {
                if ($("#good_name1_" + j).val() != "" && $("#class2_" + j).val() == "") {
                    //有輸入商品名稱,但沒輸入類別
                    alert("請輸入類別!");
                    settab("#tran");
                    $("#class2_" + j).focus();
                    return false;
                }
                if (br_form.checkclass(j) == false) {//檢查類別範圍0~45
                    $("#class2_" + j).focus();
                    return false;
                }
                if ($("#class2_" + j).val() != "") {
                    inputCount++;//實際有輸入才要+
                }
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
    var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_pul", "mod_oth", "mod_oth1", "mod_oth2", "mod_dmt"];
    for (var m in arr_mod) {
        if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
            $("#tfgp_" + arr_mod[m]).val("Y");
        } else {
            $("#tfgp_" + arr_mod[m]).val("N");
        }

    }
    if ($("#tfzr_mod_agt").prop("checked") == true) {
        if ($("input[name=tfzr_mod_agttype]").prop("checked").length == 0) {
            $("#tfgp_mod_agttype").val("N");
        } else {
            $("#tfgp_mod_agttype").val($("input[name=tfzr_mod_agttype]:checked").val());
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
