//依案性切換要顯示的欄位
main.changeTag = function (T1) {
    var code3 = T1.Left(3).toUpperCase();//案性前3碼
    var arcase = T1;//案性
    var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
    var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

    $("[id^='div_Form_'").hide();//隱藏所有交辦form
    //console.log(code3, arcase, prt_code, pagt_no);
    //依ar_form控制要顯示的欄位
    switch (main.ar_form) {
        case "A3"://註冊費
            switch (code3) {
                case "FF0": case "FF4":
                    $("#smark2,#smark").hide();
                    $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                    if (code3 == "FF0") {
                        $("#span_issue_money").html("自審定書送達之次日起2個月內，應繳納");
                    } else {
                        $("#span_issue_money").html("自審定書送達之次日起2個月期限屆期後6個月內，應繳納2倍");
                        $("#tabrem4").show();
                    }
                    $("#no1,no2").show();
                    $("#no3,no4").hide();
                    break;
                case "FF1":
                    $("#smark2,#smark").hide();
                    $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                    $("#span_issue_money").html("第一期(第一至第三年)");
                    $("#no1,no2").show();
                    $("#no3,no4").hide();
                    break;
                case "FF2":
                    $("#smark2,#smark").show();
                    $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                    $("#span_issue_money").html("第二期(第四至第十年)");
                    $("#no1,no2").hide();
                    $("#no3,no4").show();
                    break;
                case "FF3":
                    $("#smark2,#smark").show();
                    $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                    $("#span_issue_money").html("第一加倍繳納第二期(第四至第十年)");
                    $("#no1,no2").hide();
                    $("#no3,no4").show();
                    break;
            }
            break;
        case "A4"://延展
            $("#div_Form_FR").show();
            br_form.bind = br_form.bindFR;
            break;
        case "A5"://分割
            switch (code3) {
                case "FD1":
                    $("#div_Form_FD1").show();
                    br_form.bind = br_form.bindFD1;
                    $("#smark").hide();
                    $("#fr_smark1,#fr_smark3").show();
                    $("#fr_smark2").hide();
                    break;
                case "FD2": case "FD3":
                    $("#div_Form_FD2").show();
                    br_form.bind = br_form.bindFD2;
                    $("#smark").show();
                    $("#fr_smark1,#fr_smark3").show();
                    $("#fr_smark2").hide();
                    break;
            }
            $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
            break;
        case "A6"://變更
            $("#tabap,#FC0_tabap,#FC1_tabap").hide();
            $("#CTab td.tab[href='#apcust']").html("案件申請人(變更)");

            switch (arcase) {
                case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
                    $("#FC1_tabap,#div_Form_FC1").show();
                    br_form.bind = br_form.bindFC1;
                    $("#smark").hide();
                    if (arcase == "FCA") {
                        $("#FC1_tr_addagtno").show();//新增代理人
                    } else {
                        $("#FC1_tr_addagtno").hide();
                    }
                    break;
                case "FC11": case "FC15": case "FC7": case "FCH":
                    $("#FC1_tabap,#div_Form_FC11").show();
                    br_form.bind = br_form.bindFC11;
                    $("#smark").hide();
                    $("#dseqa_1").lock().val("");
                    $("#dseq1a_1").lock().val("_");
                    $("#btndseq_oka_1,#btncasea_1").hide();
                    $("#s_marka_1").val("");
                    $("#appl_namea_1,#apply_noa_1").val("");
                    $("#case_stat1a_1NN").prop("checked", true);
                    break;
                case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
                    $("#FC0_tabap,#div_Form_FC2").show();
                    br_form.bind = br_form.bindFC2;
                    $("#smark").hide();
                    $("#tabbr2").show();
                    if (arcase == "FCC") {
                        $("#FC2_tr_addagtno").show();//新增代理人
                    } else {
                        $("#FC2_tr_addagtno").hide();
                    }
                    break;
                case "FC21": case "FC6": case "FC8": case "FCI":
                    $("#FC0_tabap,#div_Form_FC21").show();
                    br_form.bind = br_form.bindFC21;
                    $("#smark").show();
                    $("#dseqb_1").lock().val("");
                    $("#dseq1b_1").lock().val("_");
                    $("#btndseq_okb_1,#btncaseb_1").hide();
                    $("#s_markb_1").val("");
                    $("#appl_nameb_1,#issue_nob_1").val("");
                    $("#case_stat1b_1NN").prop("checked", true);
                    break;
                case "FC3":
                    $("#tabap,#div_Form_FC3").show();
                    br_form.bind = br_form.bindFC3;
                    $("#CTab td.tab[href='#apcust']").html("案件申請人");
                    $("#span_FC").html("貳、申請人");
                    $("#smark").show();
                    break;
                case "FC4":
                    $("#tabap,#div_Form_FC4").show();
                    br_form.bind = br_form.bindFC4;
                    $("#span_FC").html("參、申請人(填寫變更後之正確資料)");
                    $("#smark").show();
                    break;
            }
            if (arcase == "FC11" || arcase == "FC21" || arcase == "FC5" || arcase == "FC6" || arcase == "FC7" || arcase == "FC8" || arcase == "FCH" || arcase == "FCI") {
                $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
            } else {
                $('#tfy_case_stat option:eq(1)').val("SN").text("新案(指定編號)");//案件種類
            }
            break;
        case "A7"://授權
            $("#div_Form_FL1").show();
            br_form.bind = br_form.bindFL1;
            $("[id^='tabrem']").hide();
            var tabid = arcase.substr(2, 1);
            if (arcase == "FL5")//授權一案多件同FL1
                tabid = "1";
            else if (arcase == "FL6")//再授權一案多件同FL2
                tabid = "2";
            $("#tabrem" + tabid).show();

            $("input[id^='v2'").val("");//清除專用權人資料
            //附件清空
            $("input[name^='ttz1_'").prop("checked", false);
            $("input[name^='ttz2_'").prop("checked", false);
            $("input[name^='ttz3_'").prop("checked", false);
            $("input[name^='ttz4_'").prop("checked", false);
            $("#tfzd_remark1").val("");

            $("#tabfl5").hide();//FL5,FL6一案多件表格畫面
            switch (code3) {
                case "FL1": case "FL5":
                    $("#tg_FL1,#tg_FL2").hide();
                    $("#mark1,#mark2").show();//2012/7/1新申請書增加
                    $("#term").html("柒、<u>授權期間：</u>");
                    $("#tg_term1").html("授權期間");
                    $("#tg_term2").html("");
                    $("#term1").attr("colspan", 3);
                    $("#term2").show();
                    $("#td_tm1").attr("rowspan", 2);
                    $("#tr_claim1").show();//授權期間無迄日
                    $("#markA").html("授權人(商標權人)");
                    $("#markB").html("");
                    $("#tg_type").html("捌、授權性質");
                    $("#tg_area").html("玖、授權區域");
                    $("#tg_good").html("拾、<u>授權商品或服務：</u>");
                    //授權性質/授權區域/授權商品或服務
                    $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").show();
                    $("#tg_attech").html("<u>附件：</u>");
                    $("#oth_FL").html("再授權案");
                    $("#O_item2FL2").val("FL2");
                    if (code3 == "FL5") {
                        $("#tabfl5").show();
                        $("#sp_titlecnt").html("授權");
                    }
                    break;
                case "FL2": case "FL6":
                    $("#tg_FL1,#tg_FL2").hide();
                    $("#mark1,#mark2").show();//2012/7/1新申請書增加
                    $("#term").html("柒、<u>再授權期間：</u>");
                    $("#tg_term1").html("授權期間");
                    $("#tg_term2").html("");
                    $("#term1").attr("colspan", 3);
                    $("#term2").show();
                    $("#td_tm1").attr("rowspan", 2);
                    $("#tr_claim1").show();//授權期間無迄日
                    $("#markA").html("授權人");
                    $("#markB").html("");
                    $("#tg_type").html("捌、再授權性質");
                    $("#tg_area").html("玖、再授權區域");
                    $("#tg_good").html("拾、<u>再授權商品或服務：</u>");
                    //授權性質/授權區域/授權商品或服務
                    $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").show();
                    $("#tg_attech").html("<u>附件：</u>");
                    //FL2_AP_Add_button_onclick
                    $("#oth_FL").html("授權案");
                    $("#O_item2FL2").val("FL1");
                    if (code3 == "FL6") {
                        $("#tabfl5").show();
                        $("#sp_titlecnt").html("再授權");
                    }
                    break;
                case "FL3":
                    $("#tg_FL1,#tg_FL2").hide();
                    $("#mark1,#mark2").hide();
                    $("#term").html("柒、<u>終止授權日期：</u>");
                    $("#tg_term1").html("終止日期");
                    $("#tg_term2").html("起廢止授權");
                    $("#term1").attr("colspan", 7);
                    $("#term2").hide();
                    $("#td_tm1").attr("rowspan", 1);
                    $("#tr_claim1").hide();//授權期間無迄日
                    $("#markA").html("授權人(商標權人)");
                    $("#markB").html("");
                    //授權性質/授權區域/授權商品或服務
                    $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                    $("#tg_attech").html("<u>附件：</u>");
                    break;
                case "FL4":
                    $("#tg_FL1,#tg_FL2").hide();
                    $("#mark1,#mark2").hide();
                    $("#term").html("柒、<u>廢止再授權日期：</u>");
                    $("#tg_term1").html("終止日期");
                    $("#tg_term2").html("起廢止再授權");
                    $("#term1").attr("colspan", 7);
                    $("#term2").hide();
                    $("#td_tm1").attr("rowspan", 1);
                    $("#tr_claim1").hide();//授權期間無迄日
                    $("#markA").html("授權人(係原再授權登記案之授權人)");
                    $("#markB").html("(再授權使用人)");
                    //授權性質/授權區域/授權商品或服務
                    $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                    $("#tg_attech").html("<u>附件：</u>");
                    break;
            }
            break;
        case "A8"://移轉
            $("#div_Form_FT1").show();
            br_form.bind = br_form.bindFT1;
            if (code3 == "FT1") {
                $("#tabft2").hide();
            } else if (code3 == "FT2") {
                $("#tabft2").show();
            }
            break;
        case "A9"://質權
            $("#div_Form_FP1").show();
            br_form.bind = br_form.bindFP1;
            if (code3 == "FP1") {
                $("#smark1,#smark2,#smark3").hide();
                $("#tabrem1").show();
                $("#tabrem2").hide();
                $("#tfzd_remark1").val("");
            } else if (code3 == "FP2") {
                $("#smark1,#smark2,#smark3").hide();
                $("#tabrem1").hide();
                $("#tabrem2").show();
                $("#tfzd_remark1").val("");
            }
            break;
        case "AA"://各種證明書
            $("#div_Form_FN1").show();
            br_form.bind = br_form.bindFN1;
            break;
        case "AB"://補(換)發證
            $("#div_Form_FI1").show();
            br_form.bind = br_form.bindFI1;
            break;
        case "AC"://閱案
            $("#div_Form_FV1").show();
            br_form.bind = br_form.bindFV1;
            break;
        case "B"://爭議案
            if (prt_code == "DO1") {
                $("#div_Form_DO1").show();
                br_form.bind = br_form.bindDO1;
            } else if (prt_code == "DR1") {
                $("#div_Form_DR1").show();
                br_form.bind = br_form.bindDR1;
            } else if (prt_code == "DI1") {
                $("#div_Form_DI1").show();
                br_form.bind = br_form.bindDI1;
            } else if (prt_code == "B5C1") {
                $("#div_Form_B5C1").show();
                br_form.bind = br_form.bindB5C1;
            } else {
                $("#div_Form_BZZ1").show();
                br_form.bind = br_form.bindBZZ1;
            }

            var d_agt_no1 = "";
            switch (main.branch) {
                case 'N': d_agt_no1 = "034"; break;
                case 'C': d_agt_no1 = "027"; break;
                case 'S': d_agt_no1 = "006"; break;
                case 'K': d_agt_no1 = "006"; break;
            }

            //有案性預設出名代理人
            if (pagt_no != "") {
                $("#tfp4_agt_no").val(pagt_no);
            } else {
                $("#tfp4_agt_no").val(d_agt_no1);
            }

            //聽證B5C1控制
            if (code3 == "AD7" || code3 == "DE1") {
                $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
                $("#tr_de2_item,#tr_de2_item1").hide();
                $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
                $("#span_case").html("舉行");
                $("#span_case1").html("肆、對造當事人");
                $("#span_other_item2").html("代 理 人");
                $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
            } else if (code3 == "AD8" || code3 == "DE2") {
                $("#tr_remark3,#tr_de2_item,#tr_de2_item1").show();
                $("#tr_tran_mark,#tr_de1_ap").hide();
                $("#span_dmttemp_mark").html("<input type=radio name=fr4_Mark value='B'>爭議案申請人或異議人<input type=radio name=fr4_Mark value='I'>系爭商標商標權人<input type=radio name=fr4_Mark value='R'>利害關係人");
                $("#span_case").html("出席");
                $("#span_case1").html("參、出席代表姓名或代理姓名");
                $("#span_other_item").html("指定發言姓名");
                $("#span_other_item1").html("職　　稱");
                $("#span_other_item2").html("聯絡電話");
                $("#span_tran_remark1").html("<strong>附註：新事證及陳述意見書</strong>");
            }
            break;
        default://其他
            if (prt_code == "FOB" || prt_code == "FOF" || prt_code == "FB7" || prt_code == "B5C1") {
                $("#div_Form_" + prt_code).show();
                eval("br_form.bind = br_form.bind" + prt_code);
            } else {
                $("#div_Form_ZZ1").show();
                br_form.bind = br_form.bindZZ1;
            }

            //預設代理人
            if ($("#d_agt_no1").val() == "") {
                //2015/10/21改抓cust_code
                $("#d_agt_no1").val(get_tagtno("N").no)
            }

            //有案性預設出名代理人
            if (pagt_no != "") {
                $("#tfg1_agt_no1").val(pagt_no);
                $("#tfp4_agt_no").val(pagt_no);
            } else {
                $("#tfg1_agt_no1").val($("#d_agt_no1").val());
                $("#tfp4_agt_no").val($("#d_agt_no1").val());
            }

            //申請撤回畫面控制
            if (arcase == "FW1") {
                $("#tr_zz").hide();
                $("#tr_fw1").show();
            } else {
                $("#tr_zz").show();
                $("#tr_fw1").hide();
            }

            //聽證B5C1控制
            if (code3 == "AD7") {
                $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
                $("#tr_de2_item,#tr_de2_item1").hide();
                $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
                $("#span_case").html("舉行");
                $("#span_case1").html("肆、對造當事人");
                $("#span_other_item2").html("代 理 人");
                $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
            } else if (code3 == "AD8") {
                $("#tr_remark3,#tr_de2_item,#tr_de2_item1").show();
                $("#tr_tran_mark,#tr_de1_ap").hide();
                $("#span_dmttemp_mark").html("<input type=radio name=fr4_Mark value='B'>爭議案申請人或異議人<input type=radio name=fr4_Mark value='I'>系爭商標商標權人<input type=radio name=fr4_Mark value='R'>利害關係人");
                $("#span_case").html("出席");
                $("#span_case1").html("參、出席代表姓名或代理姓名");
                $("#span_other_item").html("指定發言姓名");
                $("#span_other_item1").html("職　　稱");
                $("#span_other_item2").html("聯絡電話");
                $("#span_tran_remark1").html("<strong>附註：新事證及陳述意見書</strong>");
            }

            //影印內容
            $("input[name^='ttz1_P'").prop("checked", false);
            $("[id^='P'][id$='_new_no']").val("");
            $("[id^='P'][id$='_mod_dclass']").val("");
            $("input[name='fr_mark']").prop("checked", false);//程序種類
            break;
    }

    //切換後重新綁資料
    br_form.bind();
}
