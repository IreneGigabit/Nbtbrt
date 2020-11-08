main.savechk = function () {
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
            for (var j = 1; j <= CInt($("#num2").val()); j++) {
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
        for (var r = 1; r <= CInt($("#num2").val()); r++) {
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

    //reg.action="Brt11AddA4.asp"
    //$("#submittask").val("Add");
    //If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
    //reg.Submit
}
