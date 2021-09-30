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
        if (main.seq != "") {//查詢頁面有選舊案
            $("#tfy_case_stat").val("OO").triggerHandler("change");
            $("#old_seq").val(main.seq);
            $("#old_seq1").val(main.seq1);
            $("#btnseq_ok").click();
            //客戶
            $("#F_cust_area").val(main.cust_area);
            $("#F_cust_seq").val(main.cust_seq);
            $("#btncust_seq").click();
            //聯絡人
            attent_form.getatt($("#tfy_cust_area").val(), $("#tfy_cust_seq").val());
            $("#tfy_att_sql").val("").triggerHandler("change");
            getdmtap(main.seq, main.seq1);
        } else {
            //***聯絡人與客戶資料	
            //$("#F_cust_area").val(jMain.case_main[0].cust_area);
            //$("#F_cust_seq").val(jMain.case_main[0].cust_seq);
            $("#F_cust_area").val(jMain.cust[0].cust_area);
            $("#F_cust_seq").val(jMain.cust[0].cust_seq);
            $("#btncust_seq").click();
            //取得客戶聯人清單
            attent_form.getatt(jMain.cust[0].cust_area, jMain.cust[0].cust_seq);
            //$("#tfy_att_sql").val(jMain.case_main[0].att_sql);
            //$("#tfy_att_sql").val(jMain.cust[0].att_sql).triggerHandler("change");;
            $("#tfy_att_sql option[value='" + jMain.cust[0].att_sql + "']").prop("selected", true);
            $("#tfy_att_sql").triggerHandler("change");
            //申請人
            apcust_form.getapp(jMain.cust[0].apcust_no, main.in_no);
        }
        //***變更後申請人
        if (apcust_form.getappy) apcust_form.getappy(jMain.cust[0].apcust_no, main.in_no);
        //***變更後申請人
        if (apcust_form.getappy1) apcust_form.getappy1(jMain.cust[0].apcust_no, main.in_no);
        //收費與接洽事項
        //　洽案營洽
        $("#F_tscode").val(jMain.br_in_scode);
        $("#span_tscode").html(jMain.br_in_scname);
        //　案件主檔請款註記
        $("#tfy_Ar_mark").val("N");
        //期限
        $("#dfy_cust_date").val("");
        $("#dfy_pr_date").val(new Date().addDays(15).format("yyyy/M/d"));
        $("#dfy_last_date").val("");
        $("#nfy_tot_case").val("0");
        $("#nfy_oth_money").val("0");
        $("#tfz1_seq1").val("_");
        $("#showseq1").hide();
        settab("#case");//收費與接洽事項

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
        $("#code_type").val(jMain.case_main[0].arcase_type);
        $("#in_scode").val(jMain.case_main[0].in_scode);
        $("#in_no").val(jMain.case_main[0].in_no);
        $("#in_date").val(dateReviver(jMain.case_main[0].in_date, "yyyy/M/d"));//欄位同名會順便序號
        //　洽案營洽
        $("#F_tscode").val(jMain.br_in_scode);
        $("#span_tscode").html(jMain.br_in_scname);
        //***聯絡人與客戶資料	
        $("#F_cust_area").val(jMain.case_main[0].cust_area);
        $("#F_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#btncust_seq").click();
        $("#O_cust_area").val(jMain.case_main[0].cust_area);
        $("#O_cust_seq").val(jMain.case_main[0].cust_seq);
        $("#nfy_tot_case").val(jMain.case_main[0].nfy_tot_case);//案性數
        //取得客戶聯人清單
        attent_form.getatt(jMain.case_main[0].cust_area, jMain.case_main[0].cust_seq);
        //$("#tfy_att_sql").val(jMain.case_main[0].att_sql).triggerHandler("change");;
        $("#tfy_att_sql option[value='" + jMain.case_main[0].att_sql + "']").prop("selected", true);
        $("#tfy_att_sql").triggerHandler("change");
        $("#oatt_sql").val(jMain.case_main[0].att_sql);

        //****申請人
        apcust_form.getapp("", jMain.case_main[0].in_no);
        for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
            $("#queryap_" + r).val("重新取得申請人資料");
        }
        //***變更後申請人
        if (apcust_form.getappy) apcust_form.getappy(jMain.cust[0].apcust_no, main.in_no);
        //***變更後申請人
        if (apcust_form.getappy1) apcust_form.getappy1(jMain.cust[0].apcust_no, main.in_no);
        //***申請人種類(apcust_FC_RE_form)
        $("input[name='tfzd_Mark'][value='" + jMain.case_main[0].mark + "']").prop('checked', true).triggerHandler("click");
        //***原申請人(apcust_FC_RE1_form)
        var tranlist = $(jMain.case_tranlist).filter(function (i, n) { return n.mod_field === 'mod_ap' });
        $.each(tranlist, function (i, item) {
            //增加一筆
            $("#FC1_AP_Add_button").click();
            //填資料
            var nRow = $("#FC1_apnum").val();
            $("#dbmo1_old_no_" + nRow).val(item.old_no);
            $("#dbmo1_ocname1_" + nRow).val(item.ocname1);
            $("#dbmo1_ocname2_" + nRow).val(item.ocname2);
            $("#dbmo1_oename1_" + nRow).val(item.oename1);
            $("#dbmo1_oename2_" + nRow).val(item.oename2);
            $("#dbmo1_ocrep_" + nRow).val(item.ocrep);
            $("#dbmo1_oerep_" + nRow).val(item.oerep);
            $("#dbmo1_oaddr1_" + nRow).val(item.oaddr1);
            $("#dbmo1_oaddr2_" + nRow).val(item.oaddr2);
            $("#dbmn1_oeaddr1_" + nRow).val(item.oeaddr1);
            $("#dbmn1_oeaddr2_" + nRow).val(item.oeaddr2);
            $("#dbmn1_oeaddr3_" + nRow).val(item.oeaddr3);
            $("#dbmn1_oeaddr4_" + nRow).val(item.oeaddr4);
            $("#dbmo1_otel0_" + nRow).val(item.otel0);
            $("#dbmo1_otel_" + nRow).val(item.otel);
            $("#dbmo1_otel1_" + nRow).val(item.otel1);
            $("#dbmo1_ofax_" + nRow).val(item.ofax);
            $("#dbmo1_ozip_" + nRow).val(item.ozip);
        });
        //****後續交辦作業序號	
        $("#grconf_sqlno").val(jMain.case_main[0].grconf_sqlno);
        $("#hgrconf_sqlno").val(jMain.case_main[0].grconf_sqlno);
        //Table(case_dmt)案件主檔
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
        //$("#contract_type").hide();//***後續案無契約書
        if (jMain.case_main[0].contract_flag == "Y") {
            $("#tfy_contract_flag").prop('checked', true).triggerHandler("click");
            $("#tfy_contract_remark").val(jMain.case_main[0].contract_remark);
        }
        $("#tfy_contract_type").val(jMain.case_main[0].contract_type);
        $("input[name='Contract_no_Type'][value='" + jMain.case_main[0].contract_type + "']").prop('checked', true).triggerHandler("click");
        if (jMain.case_main[0].contract_type == "M") {
            $("#Mcontract_no").val(jMain.case_main[0].contract_no);
            $("#span_btn_contract").show();
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
        /*//轉帳金額合計抓收費標準
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
                $("#dialog").dialog({ title: '轉帳金額合計抓收費標準失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });*/
        //****折扣請核單
        $("#tfy_discount_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        //*****請款單	
        $("#tfy_ar_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        $("#tfy_ar_chk1[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
        //*****結案/復案
        $("#tfy_end_flag,#oend_flag").val(jMain.case_main[0].end_flag);//結案註記
        $("#tfy_end_type").val(jMain.case_main[0].end_type).triggerHandler("change");//結案原因
        $("#A9Z_end_type").val(jMain.case_main[0].end_type).triggerHandler("change");//結案原因
        $("#tfy_end_remark,#A9Z_end_remark").val(jMain.case_main[0].end_remark);//結案說明
        $("#tfy_back_flag,#oback_flag").val(jMain.case_main[0].back_flag);//復案註記
        $("#tfy_back_remark,#A9Z_back_remark").val(jMain.case_main[0].back_remark);//復案說明
        $("#A9Z_end_flag[value='" + jMain.case_main[0].end_flag + "']").prop('checked', true);
        $("#A9Z_back_flag[value='" + jMain.case_main[0].back_flag + "']").prop('checked', true);
        //****2011/2/15交辦維護作業，判斷結案/復案註記是否可修改，已勾選不能修改
        if (main.prgid == "brt52") {
            if (jMain.case_main[0].end_flag == "Y") {
                $("#A9Z_end_flag").lock();
            }
            if (jMain.case_main[0].back_flag == "Y") {
                $("#A9Z_back_flag").lock();
            }
        }

        //****Table(dmt_temp)案件內容
        //$("#tfg1_agt_no1").val(jMain.case_main[0].agt_no);//*出名代理人代碼
        //$("#tfzd_agt_no").val(jMain.case_main[0].agt_no);//*出名代理人代碼

        //*****案件主檔
        if (jMain.case_main[0].case_stat.Left(1) == "N") {
            $("#tfy_case_stat").val("NN");
        } else if (jMain.case_main[0].case_stat.Left(1) == "S") {
            $("#tfy_case_stat").val("SN");
        } else if (jMain.case_main[0].case_stat.Left(1) == "O") {
            $("#tfy_case_stat").val("OO");
        }
        if ($("#tfy_case_stat").val() == "NN") {
            $("#New_seq,#tfzb_seq").val(jMain.case_main[0].seq);
            $("#New_seq1,#tfzb_seq1").val(jMain.case_main[0].seq1);
        } else if ($("#tfy_case_stat").val() == "SN") {
            $("#New_Ass_seq,#tfzb_seq").val(jMain.case_main[0].seq);
            $("#New_Ass_seq1,#tfzb_seq1").val(jMain.case_main[0].seq1);
        } else if ($("#tfy_case_stat").val() == "OO") {
            $("#old_seq,#tfzb_seq").val(jMain.case_main[0].seq);
            $("#old_seq1,#tfzb_seq1").val(jMain.case_main[0].seq1);
            $("#btnseq_ok").lock();
            $("#keyseq").val("Y");
            $("#A9Ztr_backflag").show();
            //2011/2/11因結案進行中要進行復案，檢查有無結案進行中
            chkseqdata(jMain.case_main[0].seq, jMain.case_main[0].seq1);
        }
        if (main.prgid != "brt52") {
            $("#New_seq1").triggerHandler("change");
        }
        dmt_form.new_oldcase();
        $("#tfzd_issue_no,#fr_issue_no,#O_issue_no").val(jMain.case_main[0].issue_no);//*註冊號
        $("#tfzd_appl_name,#fr_appl_name").val(jMain.case_main[0].appl_name);//*商標名稱
        $("#tfzd_cust_prod").val(jMain.case_main[0].cust_prod);//*客戶卷號
        $("#tfzd_Oappl_name").val(jMain.case_main[0].oappl_name);//*不單獨主張專用權
        $("#tfzd_apply_no,#O_apply_no").val(jMain.case_main[0].apply_no);//*申請號數

        //商標種類
        $("#tfzd_S_Mark").val(jMain.case_main[0].s_mark);
        $("input[name='tfzy_S_Mark'][value='" + jMain.case_main[0].s_mark + "']").prop("checked", true);
        //商標種類2
        $("input[name='tfzd_s_mark2'][value='" + jMain.case_main[0].s_mark2 + "']").prop("checked", true);

        //*正聯防商標
        $("#tfzy_Pul").val(jMain.case_main[0].pul).triggerHandler("change");
        $("#tfzd_Pul").val(jMain.case_main[0].pul).triggerHandler("change");
        $("#tfzd_Tcn_ref").val(jMain.case_main[0].tcn_ref);
        $("#tfzd_Tcn_Class").val(jMain.case_main[0].tcn_class);
        $("#tfzd_Tcn_name").val(jMain.case_main[0].tcn_name);
        $("#tfzd_Tcn_mark").val(jMain.case_main[0].tcn_mark);

        //母案本所編號
        $("#tfzd_ref_no").val(jMain.case_main[0].ref_no);
        $("#tfzd_ref_no1").val(jMain.case_main[0].ref_no1);

        $("#tfzd_Cappl_name").val(jMain.case_main[0].cappl_name);//圖樣中文部份
        $("#tfzd_Eappl_name").val(jMain.case_main[0].eappl_name);//外文
        $("#tfzd_eappl_name1").val(jMain.case_main[0].eappl_name1);//中文字義
        $("#tfzd_eappl_name2").val(jMain.case_main[0].eappl_name2);//讀音
        $("#tfzd_Zname_type,#tfzy_Zname_type").val(jMain.case_main[0].zname_type);//語文別
        $("#tfzd_Draw").val(jMain.case_main[0].draw);//圖形描述
        $("#tfzd_Symbol").val(jMain.case_main[0].symbol);//記號說明

        $("#Draw_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑
        $("#file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
        $("#draw_attach_file").val(jMain.case_main[0].draw_file);//*圖檔實際路徑-for編修時記錄原檔名-2013/11/26增加
        if ($("#Draw_file").val() != "") {
            $("#butUpload").prop("disabled", true);
        }
        //圖樣顏色
        $("#tfzd_color").val(jMain.case_main[0].color);
        if (jMain.case_main[0].color == "B") {
            $("#tfzy_colorB").prop("checked", true);//墨色
        } else if (jMain.case_main[0].color == "C" || jMain.case_main[0].color == "M") {
            $("#tfzy_colorC").prop("checked", true);//彩色
        } else {
            $("#tfzy_colorX").prop("checked", true);//無
        }
        $("#pfzd_prior_date").val(dateReviver(jMain.case_main[0].prior_date, "yyyy/M/d"));//優先權申請日
        $("#tfzy_prior_country,#tfzd_prior_country").val(jMain.case_main[0].prior_country);//優先權首次申請國家
        $("#tfzd_prior_no").val(jMain.case_main[0].prior_no);//優先權申請案號
        $("#tfzd_apply_date").val(dateReviver(jMain.case_main[0].apply_date, "yyyy/M/d"));//申請日期
        $("#tfzd_issue_date").val(dateReviver(jMain.case_main[0].issue_date, "yyyy/M/d"));//註冊日期
        $("#tfzd_open_date").val(dateReviver(jMain.case_main[0].open_date, "yyyy/M/d"));//公告日期
        $("#tfzd_rej_no,#O_rej_no").val(jMain.case_main[0].rej_no);//核駁號
        $("#tfzd_end_date").val(dateReviver(jMain.case_main[0].end_date, "yyyy/M/d"));//結案日期
        $("#tfzy_end_code,#tfzd_end_code").val(jMain.case_main[0].end_code);//結案代碼
        $("#tfzd_dmt_term1").val(dateReviver(jMain.case_main[0].dmt_term1, "yyyy/M/d"));//專用期限
        $("#tfzd_dmt_term2").val(dateReviver(jMain.case_main[0].dmt_term2, "yyyy/M/d"));//專用期限
        $("#tfzd_renewal").val(jMain.case_main[0].renewal);//延展次數

        //**類別種類
        $("input[name='tfzr_class_type'][value='" + jMain.case_main[0].class_type + "']").prop('checked', true).triggerHandler("click");
        //指定使用商品／服務類別
        /*if (jMain.case_good.length > 0) {
            $("#tfzr_class").val(jMain.case_main[0].class);//*類別
            $("#tfzr_class_count").val(jMain.case_good.length);//共N類
            dmt_form.Add_class(jMain.case_good.length);//產生筆數
            $.each(jMain.case_good, function (i, item) {
                if (item.case_sqlno == 0) {
                    $("#class1_" + (i + 1)).val(item.class);//第X類
                    $("#good_count1_" + (i + 1)).val(item.dmt_goodcount);//共N項
                    $("#grp_code1_" + (i + 1)).val(item.dmt_grp_code);//商品群組代碼
                    $("#good_name1_" + (i + 1)).val(item.dmt_goodname);//商品名稱
                }
            });
        }*/
        var d_case_good = $(jMain.case_good).filter(function (j, n) { return n.case_sqlno === 0 });
        if (d_case_good.length > 0) {
            $("#tfzr_class").val(jMain.case_main[0].class);//*類別
            $("#tfzr_class_count").val(d_case_good.length);//共N類
            dmt_form.Add_class(d_case_good.length);//產生筆數
            $.each(d_case_good, function (ix, it) {
                $("#class1_" + (ix + 1)).val(it.class);//第X類
                $("#good_count1_" + (ix + 1)).val(it.dmt_goodcount);//共N項
                $("#grp_code1_" + (ix + 1)).val(it.dmt_grp_code);//商品群組代碼
                $("#good_name1_" + (ix + 1)).val(it.dmt_goodname);//商品名稱
            });
        }
        dmt_form.count_kind(1);////類別串接

        //**展覽優先權資料
        $("#tabshow tbody").empty();
        $("#shownum").val(0);
        $.each(jMain.case_show, function (i, item) {
            dmt_form.add_show();//展覽優先權增加一筆
            $("#show_sqlno_dmt_" + (i + 1)).val(item.show_sqlno);//流水號
            $("#show_date_dmt_" + (i + 1)).val(dateReviver(item.show_date, "yyyy/M/d"));//展覽會優先權日
            $("#show_name_dmt_" + (i + 1)).val(item.show_name);//展覽會名稱
        });

        //文件上傳
        var fld = $("#uploadfield").val();
        $("#tabfile" + fld + ">tbody").empty();
        $("#" + fld + "_filenum").val("0");
        upload_form.bind(jMain.case_attach, true);//顯示上傳文件資料/是否顯示原始檔名
        /*$.each(jMain.case_attach, function (i, item) {
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
    //*****交辦內容綁定(function在各自的form.ascx)
    if (main.ar_form == "A3") {
        br_form.bindFF();
    }
    else if (main.ar_form == "A4") {
        br_form.bindFR1();
    }
    else if (main.ar_form == "A5") {
        br_form.bindFD1();
        br_form.bindFD2();
    } else if (main.ar_form == "A6") {
        br_form.bindFC1();
        br_form.bindFC11();
        br_form.bindFC2();
        br_form.bindFC21();
        br_form.bindFC3();
        br_form.bindFC4();
    } else if (main.ar_form == "A7") {
        br_form.bindFL1();
    } else if (main.ar_form == "A8") {
        br_form.bindFT1();
    } else if (main.ar_form == "A9") {
        br_form.bindFP1();
    } else if (main.ar_form == "AA") {
        br_form.bindFN1();
    } else if (main.ar_form == "AB") {
        br_form.bindFI1();
    } else if (main.ar_form == "AC") {
        br_form.bindFV1();
    } else if (main.ar_form.Left(1) == "B") {
        //爭救案-異議、評定、廢止案件種類連動
        //$("#tfp1_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
        //$("#tfp2_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
        //$("#tfp3_case_stat").val($("#tfy_case_stat").val());//.triggerHandler("change");
        //br_form.new_oldcaseB('tfp1',false);
        //br_form.new_oldcaseB('tfp2',false);
        //br_form.new_oldcaseB('tfp3',false);

        br_form.bindDO1();
        br_form.bindDR1();
        br_form.bindDI1();
        br_form.bindBZZ1();
        br_form.bindB5C1();
    } else {
        br_form.bindZZ1();
        br_form.bindFOB();
        br_form.bindB5C1();
        br_form.bindFOF();
        br_form.bindFB7();
    }
}