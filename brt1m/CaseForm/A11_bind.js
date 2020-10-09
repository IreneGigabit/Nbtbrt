//資料綁定
function this_bind() {
    //取得交辦資料
    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/_case_dmt.aspx?prgid=" + main.prgid + "&right=" + main.right + "&formfunction=" + main.formFunction + "&submittask=" + $("#submittask").val() +
            "&cust_area=" + main.cust_area + "&cust_seq=" + main.cust_seq + "&in_no=" + main.in_no + "&code_type=" + main.code_type,
        async: false,
        cache: false,
        success: function (json) {
            if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_case_dmt)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            jMain = $.parseJSON(json);
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
        }
    });

    if (jMain.case_main.length == 0) {
        //無交辦資料則帶基本設定
        $("#in_date").val(Today().format("yyyy/M/d"));
        //客戶
        //$("#F_cust_area").val(jMain.case_main[0].cust_area);
        //$("#F_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#F_cust_area").val(jMain.cust[0].cust_area);
        $("#F_cust_seq").val(jMain.cust[0].cust_seq);
        $("#btncust_seq").click();
        //聯絡人
        //$("#tfy_att_sql").val(jMain.case_main[0].att_sql);
        $("#tfy_att_sql").val(jMain.cust[0].att_sql);
        attent_form.getatt(jMain.cust[0].cust_area, jMain.cust[0].cust_seq, jMain.cust[0].att_sql);
        //申請人
        apcust_form.getapp(jMain.cust[0].apcust_no, main.in_no);
        //收費與接洽事項
        //　洽案營洽
        $("#F_tscode").val(jMain.br_in_scode);
        $("#span_tscode").html(jMain.br_in_scname);
        //　案件主檔請款註記
        $("#tfy_Ar_mark").val("N");
        $("#dfy_cust_date").val("");
        $("#dfy_pr_date").val(new Date().addDays(15).format("yyyy/M/d"));
        $("#nfy_tot_case").val("0");
        $("#nfy_oth_money").val("0");
        $("#tfz1_seq1").val("_");
        $("#showseq1").hide();
        //交辦內容
        //　類別種類
        $("#tfz1_class_typeI").prop("checked", true);
    } else {
        $("#in_scode").val(jMain.case_main[0].in_scode);
        $("#in_no").val(jMain.case_main[0].in_no);
        $("#in_date").val(dateReviver(jMain.case_main[0].in_date3, "yyyy/M/d"));//欄位同名會順便序號
        //　洽案營洽
        $("#F_tscode").val(jMain.br_in_scode);
        $("#span_tscode").html(jMain.br_in_scname);
        //$("#code_type").val(jMain.case_main[0].arcase_type);
        //***聯絡人與客戶資料	
        $("#F_cust_area").val(jMain.case_main[0].cust_area);
        $("#F_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#btncust_seq").click();
        $("#O_cust_area").val(jMain.case_main[0].cust_area);
        $("#O_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#tfy_att_sql").val(jMain.case_main[0].tfy_att_sql);
        $("#oatt_sql").val(jMain.case_main[0].tfy_att_sql);
        attent_form.getatt(jMain.case_main[0].cust_area, jMain.case_main[0].cust_seq, jMain.case_main[0].att_sql);
        //****申請人
        apcust_form.getapp("", jMain.case_main[0].in_no);
        for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
            $("#queryap_" + r).val("重新取得申請人資料");
        }
        //Table(case_dmt)案件主檔
        $("#tfz1_seq").val(jMain.case_main[0].seq);
        $("#tfz1_seq1").val(jMain.case_main[0].seq1);
        //案性
        $("#code_type").val(jMain.case_main[0].arcase_type);
        $("#nfy_tot_case").val(jMain.case_main[0].nfy_tot_case);
        //接洽費用
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
        $("#Discount").val(jMain.case_main[0].discount);
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
        //轉帳金額合計抓收費標準
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/json_Fee.aspx?type=Fee&country=T&Arcase=" + jMain.case_main[0].oth_arcase,
            async: false,
            cache: false,
            success: function (json) {
                var jFee = $.parseJSON(json);
                if (jFee.length != 0) {
                    $("#oth_money").val(jFee[0].service);
                } else {
                    $("#oth_money").val("0");//轉帳金額
                }
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>轉帳金額合計抓收費標準失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '轉帳金額合計抓收費標準失敗！', modal: true, maxHeight: 500, width: 800 });
                //toastr.error("<a href='" + this.url + "' target='_new'>轉帳金額合計抓收費標準失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            }
        });
        //****折扣請核單
        $("#tfy_discount_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        //*****請款單	
        $("#tfy_ar_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        $("#tfy_ar_chk1[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");

        //****Table(dmt_temp)案件內容
        br_form.changeTag($("#tfy_Arcase").val());//依案性切換要顯示的欄位
        $("#tfz1_Appl_name").val(jMain.case_main[0].appl_name);//*商標名稱
        $("#tfz1_cust_prod").val(jMain.case_main[0].cust_prod);//20180301增加客戶卷號
        $("#tfz1_Oappl_name").val(jMain.case_main[0].oappl_name);//不單獨主張專用權
        $("#tfz1_Cappl_name").val(jMain.case_main[0].cappl_name);//商標圖樣中文
        $("#tfz1_Eappl_name").val(jMain.case_main[0].eappl_name);//商標圖樣外文
        $("#tfz1_Eappl_name1").val(jMain.case_main[0].eappl_name1);//圖樣分析中文字義
        $("#tfz1_Eappl_name2").val(jMain.case_main[0].eappl_name2);//圖樣分析讀音
        $("#tfz1_Zname_type").val(jMain.case_main[0].zname_type);//語文別
        $("#tfz1_Draw").val(jMain.case_main[0].draw);//圖形說明
        $("#tfz1_Symbol").val(jMain.case_main[0].symbol);//記號說明
        //if(main.formFunction=="Edit"){
        $("#Draw_file1").val(jMain.case_main[0].draw_file);//*圖檔實際路徑
        $("#file1").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
        $("#draw_attach_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
        if ($("#Draw_file1").val() != "") {
            $("#butUpload1").prop("disabled", true);
        }
        //}
        if (jMain.case_main[0].color == "B") {
            $("#tfz1_colorB").prop("checked", true);
        } else if (jMain.case_main[0].color == "C" || jMain.case_main[0].color == "M") {
            $("#tfz1_colorC").prop("checked", true);
        }

        //標章描述
        $("input[name=tfz1_remark3][value='" + jMain.case_main[0].remark3 + "'").prop("checked", true);
        //聲音/立體商標圖樣
        switch (jMain.case_main[0].arcase.substr(2, 1).toUpperCase()) {//案性第3碼
            case '4': case '8': case 'C': case 'G'://立體
                if (jMain.case_main[0].remark3 != "") {
                    var arr_remark3 = jMain.case_main[0].remark3.split("|");
                    for (var i = 0; i < arr_remark3.length; i++) {
                        $("#tt44_" + arr_remark3[i]).prop("checked", true);
                    }
                }
                break;
            case '3': case '7': case 'B': case 'F'://聲音
                if (jMain.case_main[0].remark3 == "Y") {
                    $("input[name=tfz1_remark3][value='Y']").prop("checked", true);
                } else {
                    $("input[name=tfz1_remark3][value='N']").prop("checked", true);
                }
                break;
        }
        $("#tfz1_agt_no").val(jMain.case_main[0].agt_no);//*出名代理人代碼
        //**優先權聲明
        $("#pfz1_prior_date").val(dateReviver(jMain.case_main[0].prior_date, "yyyy/M/d"));
        $("#tfz1_prior_country").val(jMain.case_main[0].prior_country);
        $("#tfz1_prior_no").val(jMain.case_main[0].prior_no);
        //**類別種類
        $("input[name='tfz1_class_type'][value='" + jMain.case_main[0].class_type + "']").prop('checked', true).triggerHandler("click");
        //指定使用商品／服務類別
        if ($("#tabbr1").length > 0) {//有載入才要檢查
            if (jMain.case_good.length > 0) {
                $("#tfz1_class").val(jMain.case_main[0].class);//*類別
                $("#tfz1_class_count").val(jMain.case_good.length);//共N類
                br_form.Add_class(jMain.case_good.length);//產生筆數
                $.each(jMain.case_good, function (i, item) {
                    $("#class1_" + (i + 1)).val(item.class);//第X類
                    $("#good_count1_" + (i + 1)).val(item.dmt_goodcount);//共N項
                    $("#grp_code1_" + (i + 1)).val(item.dmt_grp_code);//商品群組代碼
                    $("#good_name1_" + (i + 1)).val(item.dmt_goodname);//商品名稱
                });
            } else {
                br_form.count_kind(1);////類別串接
            }
        }
        //**表彰之內容
        $("#tf91_good_name").val(jMain.case_main[0].good_name);
        //**證明標的
        $("input[name='pul'][value='" + jMain.case_main[0].pul + "']").prop('checked', true).triggerHandler("click");
        $("#tfz1_pul").val(jMain.case_main[0].pul);
        //**證明內容
        $("#tfd1_good_name").val(jMain.case_main[0].good_name);
        //**描述實際使用說明
        $("#tfz1_Remark4").val(jMain.case_main[0].remark4);
        //**展覽優先權資料
        $.each(jMain.case_show, function (i, item) {
            br_form.add_show();//展覽優先權增加一筆
            $("#show_sqlno_" + (i + 1)).val(item.show_sqlno);//流水號
            $("#show_date_" + (i + 1)).val(dateReviver(item.show_date, "yyyy/M/d"));//展覽會優先權日
            $("#show_name_" + (i + 1)).val(item.show_name);//展覽會名稱
        });
        //**簽章及具結
        $("#tfz1_remark2").val(jMain.case_main[0].remark2);
        if (jMain.case_main[0].remark2 != "") {
            var arr_remark2 = jMain.case_main[0].remark2.split("|");
            $("#ttz1_" + arr_remark2[0] + "Code").prop('checked', true);
            if (arr_remark2.length > 1) {
                $("#ttz1_" + arr_remark2[0]).val(arr_remark2[1]);
            }
        }
        //**附件
        $("#tfz1_remark1").val(jMain.case_main[0].remark1);
        if (jMain.case_main[0].remark1 != "") {
            var arr_remark1 = jMain.case_main[0].remark1.split("|");
            for (var i = 0; i < arr_remark1.length; i++) {
                //var str="Z3|Z9|Z9-具結書正本、讓與人之負責人身份證影本-Z9|";
                var str = "Z9-具結書正本、讓與人之負責人身份證影本-Z9";
                var substr = arr_remark1[i].match(/Z9-(\S+)-Z9/);
                if (substr != null) {
                    $("#tt11_Z9t").val(substr[1]);
                } else {
                    $("#tt11_" + arr_remark1[i]).prop("checked", true);
                }
            }
        }

        //**商標種類2
        if (jMain.case_main[0].s_mark2 == "H") {
            $("input[name=tfz1_s_mark2][value='H']").prop("checked", true);//位置
        } else if (jMain.case_main[0].s_mark2 == "I") {
            $("input[name=tfz1_s_mark2][value='I']").prop("checked", true);//氣味
        } else if (jMain.case_main[0].s_mark2 == "J") {
            $("input[name=tfz1_s_mark2][value='J']").prop("checked", true);//觸覺
        }

        //文件上傳
        $.each(jMain.case_attach, function (i, item) {
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
        });
        settab("#tran");
    }
}
