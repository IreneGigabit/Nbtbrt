//資料綁定
main.bind = function () {
    //console.log("main.bind");
    $("#grconf_sqlno").val(main.qgrconf_sqlno);
    $("#hgrconf_sqlno").val(main.qgrconf_sqlno);
    if (jMain.case_main.length == 0) {
        //main.changeTag("000");//交辦內容顯示預設項目
        main.changeTag($("#tfy_Arcase option[value!='']").eq(0).val());//交辦內容顯示預設項目用第一個案性

        //無交辦資料則帶基本設定
        $("#in_date").val(Today().format("yyyy/M/d"));
        //***聯絡人與客戶資料	
        //$("#F_cust_area").val(jMain.case_main[0].cust_area);
        //$("#F_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#F_cust_area").val(jMain.cust[0].cust_area);
        $("#F_cust_seq").val(jMain.cust[0].cust_seq);
        $("#btncust_seq").click();
        //取得客戶聯人清單
        attent_form.getatt(jMain.cust[0].cust_area, jMain.cust[0].cust_seq);
        //$("#tfy_att_sql").val(jMain.case_main[0].att_sql);
        //$("#tfy_att_sql").val(jMain.cust[0].att_sql).triggerHandler("change");
        $("#tfy_att_sql option[value='" + jMain.cust[0].att_sql + "']").prop("selected", true);
        $("#tfy_att_sql").triggerHandler("change");
        //申請人
        apcust_form.getapp(jMain.cust[0].apcust_no, main.in_no);
        //收費與接洽事項
        //　洽案營洽
        $("#F_tscode").val(jMain.br_in_scode);
        $("#span_tscode").html(jMain.br_in_scname);
        //　案件主檔請款註記
        $("#tfy_Ar_mark").val("N");
        //期限
        $("#dfy_cust_date").val("");
        $("#dfy_pr_date").val(new Date().addDays(15).format("yyyy/M/d"));
        $("#nfy_tot_case").val("0");
        $("#nfy_oth_money").val("0");
        $("#tfz1_seq1").val("_");
        $("#showseq1").hide();

        if (main.prgid == "brt52") {//交辦維護
            $("button").lock();//抓不到資料就鎖定
        }
    } else {
        //標題
        $("#t_in_no").html(jMain.case_main[0].in_scode + "-" + jMain.case_main[0].in_no);
        $("#t_seq").html(jMain.case_main[0].seq + (jMain.case_main[0].seq1 != "_" ? "-" + jMain.case_main[0].seq1 : ""));
        $("#t_case_no").html(jMain.case_main[0].case_no);
        $("#t_ar_curr").html(CInt(jMain.case_main[0].ar_curr) == 0 ? "未請款" : "已請款");

        //main.changeTag(jMain.case_main[0].arcase);
        $("#in_scode").val(jMain.case_main[0].in_scode);
        $("#in_no").val(jMain.case_main[0].in_no);
        $("#in_date").val(dateReviver(jMain.case_main[0].in_date, "yyyy/M/d"));//欄位同名會順便序號
        //案性
        $("#code_type").val(jMain.case_main[0].arcase_type);
        $("#nfy_tot_case").val(jMain.case_main[0].nfy_tot_case);
        //　洽案營洽
        $("#F_tscode").val(jMain.br_in_scode);
        $("#span_tscode").html(jMain.br_in_scname);
        //***聯絡人與客戶資料	
        $("#F_cust_area").val(jMain.case_main[0].cust_area);
        $("#F_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#btncust_seq").click();
        $("#O_cust_area").val(jMain.case_main[0].cust_area);
        $("#O_cust_seq").val(jMain.case_main[0].cust_seq);
        //取得客戶聯人清單
        attent_form.getatt(jMain.case_main[0].cust_area, jMain.case_main[0].cust_seq);
        //$("#tfy_att_sql").val(jMain.case_main[0].att_sql).triggerHandler("change");
        $("#tfy_att_sql option[value='" + jMain.case_main[0].att_sql + "']").prop("selected", true);
        $("#tfy_att_sql").triggerHandler("change");

        $("#oatt_sql").val(jMain.case_main[0].att_sql);
        //****申請人
        apcust_form.getapp("", jMain.case_main[0].in_no);
        for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
            $("#queryap_" + r).val("重新取得申請人資料");
        }
        //Table(case_dmt)案件主檔
        $("#tfz1_seq").val(jMain.case_main[0].seq);
        $("#tfz1_seq1").val(jMain.case_main[0].seq1);
        //接洽費用
        $("tr[id^='tr_ta_']").remove();
        $.each(jMain.case_item, function (i, item) {
            if (item.item_sql == "0") {
                $("#tfy_Arcase").val(item.item_arcase).triggerHandler("change");
                $("#nfyi_Service").val(item.item_service);
                $("#nfyi_Fees").val(item.item_fees);
                $("#Service").val(item.service == "" ? "0" : item.service);//收費標準
                $("#Fees").val(item.fees == "" ? "0" : item.fees);//收費標準
            } else {
                case_form.ta_display('Add');
                $("#nfyi_item_Arcase_" + item.item_sql).val(item.item_arcase);
                $("#nfyi_item_count_" + item.item_sql).val(item.item_count);//項目
                $("#nfyi_Service_" + item.item_sql).val(item.item_service);
                $("#nfyi_fees_" + item.item_sql).val(item.item_fees);
                $("#nfzi_Service_" + item.item_sql).val(item.service == "" ? "0" : item.service);;//收費標準
                $("#nfzi_fees_" + item.item_sql).val(item.fees == "" ? "0" : item.fees);//收費標準
            }
            $("#TaCount").val(item.item_sql);//請款案性數
        });
        //費用小計
        $("#nfy_service").val(jMain.case_main[0].service);
        $("#nfy_fees").val(jMain.case_main[0].fees);
        //收費標準
        $("#Service").val(jMain.case_main[0].p_service);
        $("#Fees").val(jMain.case_main[0].p_fees);
        //折扣率
        $("#nfy_Discount").val(jMain.case_main[0].discount);
        $("#Discount").val(jMain.case_main[0].discount + "%");
        $("#tfy_dicount_remark").val(jMain.case_main[0].discount_remark);//***折扣理由

        //***折扣低於8折顯示折扣理由
        if (CInt($("#nfy_Discount").val()) > 20) {
            $("#span_discount_remark").show();
        }
        //***判斷收費標準
        if (jMain.case_main[0].p_service == "0" && jMain.case_main[0].p_fees == "0") {
            $("#anfees").val("N");
        } else {
            $("#anfees").val("Y");
        }
        //合計
        $("#OthSum").val(jMain.case_main[0].othsum);
        //案源代碼
        $("#tfy_source").val(jMain.case_main[0].source);
        $("#osource").val(jMain.case_main[0].source);
        //請款註記
        $("#tfy_Ar_mark").val(jMain.case_main[0].ar_mark);
        $("#tfy_ar_code").val(jMain.case_main[0].ar_code);
        br_form.seq1_conctrl();

        //*****契約號碼,2015/12/29修改，增加契約書種類，契約書後補註記及說明
        $("#contract_type").hide();//***後續案無契約書
        if (jMain.case_main[0].contract_flag == "Y") {
            $("#tfy_contract_flag").prop('checked', true).triggerHandler("click");
            $("#tfy_contract_remark").val(jMain.case_main[0].contract_remark);
        }
        $("#tfy_contract_type").val(jMain.case_main[0].contract_type);
        $("input[name='Contract_no_Type'][value='" + jMain.case_main[0].contract_type + "']").prop('checked', true).triggerHandler("click");
        if (jMain.case_main[0].contract_type == "M") {
            $("#Mcontract_no").val(jMain.case_main[0].contract_no);
        } else if (jMain.case_main[0].contract_type == "N") {
            $("#tfy_Contract_no").val(jMain.case_main[0].contract_no);
        }
        $("#ocontract_no").val(jMain.case_main[0].contract_no);
        if (main.prgid != "brt52") {//不是交辦維護
            case_form.display_caseform("T", $("#tfy_Arcase").val());//抓案性特殊控制
        }
        //期限
        $("#dfy_cust_date").val(dateReviver(jMain.case_main[0].cust_date, "yyyy/M/d"));
        $("#dfy_pr_date").val(dateReviver(jMain.case_main[0].pr_date, "yyyy/M/d"));
        $("#dfy_last_date").val(dateReviver(jMain.case_main[0].last_date, "yyyy/M/d"));
        //其他接洽事項記錄
        $("#tfy_Remark").val(jMain.case_main[0].remark);
        //20160910增加發文方式欄位
        case_form.setSendWay($("#tfy_Arcase").val());
        $("#tfy_send_way").val(jMain.case_main[0].send_way);
        //20180221增加電子收據欄位
        $("#tfy_receipt_type").val(jMain.case_main[0].receipt_type);
        $("#tfy_receipt_title").val(jMain.case_main[0].receipt_title);
        $("#tfy_rectitle_name").val(jMain.case_main[0].rectitle_name);
        //20200207若規費為0則收據抬頭預設為空白
        if (jMain.case_main[0].fees == 0) {
            $("#tfy_receipt_title").val("B");
        }

        $("#xadd_service").val(jMain.case_main[0].add_service); //追加服務費
        $("#xadd_fees").val(jMain.case_main[0].add_fees);       //追加規費
        $("#xar_service").val(jMain.case_main[0].ar_service);   //已請款服務費
        $("#xar_fees").val(jMain.case_main[0].ar_fees);         //已請款規費
        $("#xar_curr").val(jMain.case_main[0].ar_curr);         //已請款次數
        $("#xgs_fees").val(jMain.case_main[0].gs_fees);         //已支出規費
        if (jMain.case_main[0].ar_code == "X") {
            $("#chkar_code").prop("checked", true);
        } else {
            $("#chkar_code").prop("checked", false);
        }
        $("#ochkar_code").val(jMain.case_main[0].ar_code);
        //****轉帳費用
        $("#tfy_oth_arcase").val(jMain.case_main[0].oth_arcase);//轉帳費用
        $("#tfy_oth_code").val(jMain.case_main[0].oth_code);//轉帳單位
        $("#nfy_oth_money").val(jMain.case_main[0].oth_money);//轉帳金額
        $("#oth_money").val(jMain.case_main[0].casefee_oth_money);//轉帳金額合計
        //****折扣請核單
        $("#tfy_discount_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        //*****請款單	
        $("#tfy_ar_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        $("#tfy_ar_chk1[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");

        //文件上傳
        var fld = $("#uploadfield").val();
        $("#tabfile" + fld + ">tbody").empty();
        $("#" + fld + "_filenum").val("0");
        upload_form.bind(jMain.case_attach);//顯示上傳文件資料
        /*$.each(jMain.case_attach, function (i, item) {
            var fld = $("#uploadfield").val();
            upload_form.appendFile();//增加一筆
            var nRow = $("#" + fld + "_filenum").val();
            $("#" + fld + "_name_" + nRow).val(item.attach_name);
            $("#old_" + fld + "_name_" + nRow).val(item.attach_name);
            $("#" + fld + "_" + nRow).val(item.attach_path);
            $("#doc_type_" + nRow).val(item.doc_type);
            $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
            $("#" + fld + "_size_" + nRow).val(item.attach_size);
            $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
            $("#" + fld + "_apattach_sqlno_" + nRow).val(item.apattach_sqlno);//總契約書/委任書流水號
            $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
            $("#btn" + fld + "_" + nRow).prop("disabled", true);
            $("input[name='" + fld + "_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);//交辦專案室
            $("#source_name_" + nRow).val(item.source_name);
            $("#attach_no_" + nRow).val(item.attach_no);
            $("#attach_flagtran_" + nRow).val(item.attach_flagtran);//異動作業上傳註記Y
            $("#tran_sqlno_" + nRow).val(item.tran_sqlno);//異動作業流水號
            $("#maxattach_no").val(Math.max(CInt(item.attach_no), CInt($("#maxattach_no").val())));
        });*/
        settab("#tran");//交辦內容
    }
}