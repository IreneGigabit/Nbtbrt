//依案件編號抓案件資料並綁定
function delayNO(low_no, low_no1) {
    if ($("#tfy_Arcase").val() == "") {
        alert("請選擇案性!!");
        settab("#case");
        $("#tfy_Arcase").focus();
        return false;
    }
    if (low_no == "" || low_no1 == "" || !IsNumeric(low_no)){
        alert("案件編號錯誤，請重新輸入");
        return false;
    }

    //檢查案件有無結案流程進行中
    chkseqdata(low_no, low_no1);

    //20181112檢查該案件客戶有無債信不良
    if (chkcustdata(low_no,low_no1)==false){
        alert("該案件客戶債信不良！");
        $("#old_seq").val("");
        $("#old_seq1").val("_");
        $("#keyseq").val("N");
        $("#btnseq_ok").unlock();
        return false;
    }

    //取得案件資料
    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/jsonDelaySQL.aspx?delay_seq=" + low_no +
            "&delay_seq1=" + low_no1 + "&cust_area=" + $("#F_cust_area").val() +
            "&cust_seq=" + $("#F_cust_seq").val(),
        async: false,
        cache: false,
        success: function (json) {
            if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(jsonDelaySQL)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            oMain = $.parseJSON(json);
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件資料載入失敗(jsonDelaySQL)！', modal: true, maxHeight: 500, width: "90%" });
        }
    });

    if (oMain.vdmtall.length == 0) {
        $("#tfy_case_stat").val("OO");
        $("#tfzd_ref_no,#tfzd_ref_no1").val("");//母案本所編號
        $("input[name='tfzy_S_Mark']").prop("checked", false);
        $("#tfzd_S_mark").val("");
        $("input[name$=S_mark]:radio").prop("checked", false);
        $("input[name$=s_mark2]:radio").prop("checked", false).unlock();
        $("#tfzy_Pul,#tfzd_Pul,#tfzd_Tcn_ref,#tfzd_Tcn_Class,#tfzd_Tcn_name,#tfzd_Tcn_mark").val("");//正聯防
        $("#tfzd_cust_prod").val("");
        $("#tfzd_apply_no").val("");
        $("#tfzd_issue_no").val("");
        $("#tfzd_appl_name").val("");

        $("#tft1_mod_count11,#tft2_mod_count2").val("");//件數
        $("#new_no11,#apply_noa_1").val("");//申請號數
        $("#new_no21,#fr_issue_no,#fr1_issue_no,#fr2_issue_no,#fr3_issue_no,#fr4_issue_no,#issue_nob_1").val("");//註冊案號
        $("#ncname111,#ncname121,#fr_appl_name,#fr1_appl_name,#fr2_appl_name,#fr3_appl_name,#fr4_appl_name,#appl_namea_1,#appl_nameb_1,#frf_appl_name,#fbf_appl_name").val("");//商標/標章名稱
        $("#s_marka_1,#s_markb_1").val("");//商標種類

        $("#draw_attach_file,#Draw_file").val("");//圖檔檢視
        $("#tfzd_Oappl_name").val("");//聲明不專用
        $("#tfzd_Cappl_name").val("");//圖樣中文部份
        $("#tfzd_Eappl_name,#tfzd_eappl_name1,#tfzd_eappl_name2,#tfzd_Zname_type").val("");//圖樣外文部份
        $("#tfzd_Draw").val("");//圖形描述
        $("#tfzd_Symbol").val("");//記號說明
        $("input[name='tfzy_color']").prop("checked", false);//圖樣顏色
        $("#tfzd_color").val("");//圖樣顏色
        $("#pfzd_prior_date").val("");//優先權申請日
        $("#tfzy_prior_country,#tfzd_prior_country").val("");//優先權首次申請國家
        $("#tfzd_prior_no").val("");//優先權申請案號
        $("#tfzd_apply_date").val("");//申請日期
        $("#tfzd_issue_date").val("");//註冊日期
        $("#tfzd_open_date").val("");//公告日期
        $("#tfzd_rej_no").val("");//核駁號
        $("#tfzd_end_date").val("");//結案日期
        $("#tfzy_end_code,#tfzd_end_code").val("");//結案代碼
        $("#tfzd_dmt_term1,#tfzd_dmt_term2").val("");//專用期限
        $("#tfzd_renewal").val("");//延展次數
        $("#tfzr_class_count").val("");//類別數
        $("#tfzr_class").val("");//類別
        $("#class1_1").val("");
        $("#good_name1_1").val("");
        $("#good_count1_1").val("");
        $("#grp_code1_1").val("");
        alert("該客戶無此案件編號");
        $("#keyseq").val("N");
        $("#btnseq_ok").unlock();//舊案[查詢主案件編號]
    } else {
        $("#tfy_case_stat").val("OO");
        $("#tfzd_ref_no").val(oMain.vdmtall[0].mseq);//母案本所編號
        $("#tfzd_ref_no1").val(oMain.vdmtall[0].mseq1);
        //商標種類
        $("#tfzd_S_mark").val(oMain.vdmtall[0].s_mark);
        $("input[name='tfzy_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr2_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr21_S_mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr11_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr3_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr1_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr4_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='frf_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fbf_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        if (oMain.vdmtall[0].s_mark == "S") {
            $("#s_marka_1,#s_markb_1").val("92年修正前服務標章");
        } else if (oMain.vdmtall[0].s_mark == "N") {
            $("#s_marka_1,#s_markb_1").val("團體商標");
        } else if (oMain.vdmtall[0].s_mark == "M") {
            $("#s_marka_1,#s_markb_1").val("團體標章");
        } else if (oMain.vdmtall[0].s_mark == "L") {
            $("#s_marka_1,#s_markb_1").val("證明標章");
        } else {
            $("#s_marka_1,#s_markb_1").val("商標");
        }
        //正聯防
        $("#tfzy_Pul,#tfzd_Pul").val(oMain.vdmtall[0].pul).triggerHandler("change");
        $("#tfzd_Tcn_ref").val(oMain.vdmtall[0].tcn_ref);
        $("#tfzd_Tcn_Class").val(oMain.vdmtall[0].tcn_class);
        $("#tfzd_Tcn_name").val(oMain.vdmtall[0].tcn_name);
        $("#tfzd_Tcn_mark").val(oMain.vdmtall[0].tcn_mark);

        $("#tfzd_cust_prod").val(oMain.vdmtall[0].cust_prod);
        $("#tfzd_apply_no,#O_apply_no").val(oMain.vdmtall[0].apply_no);
        $("#tfzd_issue_no,#O_issue_no").val(oMain.vdmtall[0].issue_no);
        $("#tfzd_appl_name").val(oMain.vdmtall[0].appl_name);
        $("#draw_attach_file,#Draw_file").val(oMain.vdmtall[0].draw_file);//圖檔檢視

        $("#tft1_mod_count11,#tft2_mod_count2").val("1");//件數
        $("#new_no11,#fr1_apply_no,#fr_apply_no,#fbf_no").val(oMain.vdmtall[0].apply_no);//申請號數
        $("#ncname111,#ncname121,#appl_namea_1,#appl_nameb_1").val(oMain.vdmtall[0].appl_name);//商標/標章名稱
        $("#fr_appl_name,#fr1_appl_name,#fr2_appl_name,#fr3_appl_name,#fr4_appl_name,#frf_appl_name,#fbf_appl_name").val(oMain.vdmtall[0].appl_name);//商標/標章名稱
        $("#new_no21,#fr_issue_no,#fr1_issue_no,#fr2_issue_no,#fr3_issue_no,#fr4_issue_no,#issue_nob_1").val(oMain.vdmtall[0].issue_no);//註冊案號
        if ($("input[name='frf_mark']:checked").val() == "A") {//申請號數
            $("#frf_no").val(oMain.vdmtall[0].apply_no);
        } else if ($("input[name='frf_mark']:checked").val() == "I") {//註冊號數
            $("#frf_no").val(oMain.vdmtall[0].issue_no);
        } else {
            $("#frf_no").val("");
        }
        $("input[name='tfzd_Mark']:checked").triggerHandler("click");
        $("#fr_class").val(oMain.vdmtall[0].class);//類別

        $("#tfzd_Oappl_name").val(oMain.vdmtall[0].oappl_name);//聲明不專用
        $("#tfzd_Cappl_name").val(oMain.vdmtall[0].cappl_name);//圖樣中文部份
        $("#tfzd_Eappl_name").val(oMain.vdmtall[0].eappl_name);//外文
        $("#tfzd_eappl_name1").val(oMain.vdmtall[0].eappl_name1);//中文字義
        $("#tfzd_eappl_name2").val(oMain.vdmtall[0].eappl_name2);//讀音
        $("#tfzd_Zname_type,#tfzy_Zname_type").val(oMain.vdmtall[0].zname_type);//語文別
        $("#tfzd_Draw").val(oMain.vdmtall[0].draw);//圖形描述
        $("#tfzd_Symbol").val(oMain.vdmtall[0].symbol);//記號說明
        //圖樣顏色
        $("#tfzd_color").val(oMain.vdmtall[0].color);
        if (oMain.vdmtall[0].color == "B") {
            $("#tfzy_colorB").prop("checked", true);//墨色
        } else if (oMain.vdmtall[0].color == "C" || oMain.vdmtall[0].color == "M") {
            $("#tfzy_colorC").prop("checked", true);//彩色
        } else {
            $("#tfzy_colorX").prop("checked", true);//無
        }
        $("#pfzd_prior_date").val(dateReviver(oMain.vdmtall[0].prior_date, "yyyy/M/d"));//優先權申請日
        $("#tfzy_prior_country,#tfzd_prior_country").val(oMain.vdmtall[0].prior_country);//優先權首次申請國家
        $("#tfzd_prior_no").val(oMain.vdmtall[0].prior_no);//優先權申請案號
        $("#tfzd_apply_date").val(dateReviver(oMain.vdmtall[0].apply_date, "yyyy/M/d"));//申請日期
        $("#tfzd_issue_date").val(dateReviver(oMain.vdmtall[0].issue_date, "yyyy/M/d"));//註冊日期
        $("#tfzd_open_date").val(dateReviver(oMain.vdmtall[0].open_date, "yyyy/M/d"));//公告日期
        $("#tfzd_rej_no,#O_rej_no").val(oMain.vdmtall[0].rej_no);//核駁號
        $("#tfzd_end_date").val(dateReviver(oMain.vdmtall[0].end_date, "yyyy/M/d"));//結案日期
        $("#tfzy_end_code,#tfzd_end_code").val(oMain.vdmtall[0].end_code);//結案代碼
        $("#tfzd_dmt_term1").val(dateReviver(oMain.vdmtall[0].term1, "yyyy/M/d"));//專用期限
        $("#tfzd_dmt_term2").val(dateReviver(oMain.vdmtall[0].term2, "yyyy/M/d"));//專用期限
        $("#tfzd_renewal").val(oMain.vdmtall[0].renewal);//延展次數

        $("#dseqa_1,#dseqb_1,#old_seq").val(low_no);
        $("#dseq1a_1,#dseq1b_1,#old_seq1").val(low_no1);
        $("#appl_namea_1,#appl_nameb_1").val(oMain.vdmtall[0].appl_name);
        $("#apply_noa_1").val(oMain.vdmtall[0].apply_no);
        $("#issue_nob_1").val(oMain.vdmtall[0].issue_no);
        $("#keydseqa_1,#keydseqb_1").val("Y");
        $("#btndseq_oka_1,#btndseq_okb_1").lock();//[確定]
        
        $("#tfzr_class_count,#tft3_class_count2,#mod_count").val(oMain.vdmtall[0].class_count);//共N類
        $("#tfzr_class,#tft3_class2,#mod_dclass").val(oMain.vdmtall[0].class);//類別
        if (br_form.Add_classFC3) br_form.Add_classFC3(0);
        if (br_form.Add_classFL1) br_form.Add_classFL1(0);
        if (CInt($("#tfzr_class_count").val() == 0)) {
            dmt_form.Add_class(1);//類別預設顯示第1筆
            if (br_form.Add_classFC3) br_form.Add_classFC3(1);
            if (br_form.Add_classFL1) br_form.Add_classFL1(1);
        } else {
            if (oMain.dmt_good.length > 0) {
                dmt_form.Add_class(oMain.dmt_good.length);//產生筆數
                if (br_form.Add_classFC3) br_form.Add_classFC3(oMain.dmt_good.length);
                if (br_form.Add_classFL1) br_form.Add_classFL1(oMain.dmt_good.length);
                $.each(oMain.dmt_good, function (i, item) {
                    $("#class1_" + (i + 1)).val(item.class).lock();//第X類
                    $("#good_count1_" + (i + 1)).val(item.dmt_goodcount).lock();//共N項
                    $("#grp_code1_" + (i + 1)).val(item.dmt_grp_code).lock();//商品群組代碼
                    $("#good_name1_" + (i + 1)).val(item.dmt_goodname).lock();//商品名稱
                    //fc3
                    $("#class32_" + (i + 1)).val(item.class);//第X類
                    $("#good_name32_" + (i + 1)).val(item.dmt_goodname);//商品名稱
                    $("#good_count32_" + (i + 1)).val(item.dmt_goodcount);//共N項
                    //fl1
                    $("#new_no_" + (i + 1)).val(item.class);//第X類
                    $("#list_remark_" + (i + 1)).val(item.dmt_goodname);//共N商品名稱
                });
            }
            dmt_form.count_kind(1);//類別串接
            if (br_form.count_kindFC3) br_form.count_kindFC3(1);//fc3類別串接
            if (br_form.count_kindFL1) br_form.count_kindFL1(1);//fl1類別串接
        }
        var kclass_type = oMain.vdmtall[0].class_type;//案件主檔之類別種類
        var ks_mark2 = oMain.vdmtall[0].s_mark2;//案件主檔之商標種類
        $("input[name='tft3_class_type2'][value='" + kclass_type + "']").prop("checked", true);
        $("input[name='tfzr_class_type'][value='" + kclass_type + "']").prop("checked", true);
        $("input[name='tfzd_s_mark2'][value='" +ks_mark2 + "']").prop("checked", true);//商標種類2

        //展覽會優先權資料
        dmt_form.getshow("dmt");

        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)
        if (pagt_no == "") {
            pagt_no = get_tagtno("N").no;//2015/10/21因應104年度出名代理人修改並改抓取cust_code.code_type=Tagt_no and mark=N預設出名代理人
        }
        var kagt_no = oMain.vdmtall[0].agt_no;//案件主檔之出名代理人
        var kagt_name = oMain.vdmtall[0].agt_name;//案件主檔之出名代理人
        if (pagt_no != kagt_no) {
            if (confirm("預設的出名代理人與案件主檔出名代理人(" + kagt_no + kagt_name + ")不同，是否依案件主檔出名代理人資料覆蓋?")==false) {
                kagt_no = pagt_no;
            }
        }
        $("#ttg1_agt_no").val(kagt_no).triggerHandler("change");
        $("#ttg2_agt_no").val(kagt_no).triggerHandler("change");
        $("#ttg11_agt_no").val(kagt_no).triggerHandler("change");
        $("#ttg21_agt_no").val(kagt_no).triggerHandler("change");
        $("#ttg3_agt_no").val(kagt_no).triggerHandler("change");
        $("#ttg4_agt_no").val(kagt_no).triggerHandler("change");
        $("#tfg2_agt_no1").val(kagt_no).triggerHandler("change");
        $("#tfgd_agt_no1").val(kagt_no).triggerHandler("change");
        $("#tfzd_agt_no").val(kagt_no).triggerHandler("change");
        $("#tfp4_agt_no").val(kagt_no).triggerHandler("change");
        $("#tfzf_agt_no1").val(kagt_no).triggerHandler("change");
        $("#tfg1_agt_no1").val(kagt_no).triggerHandler("change");

        //結案檢查，提醒是否復案
        if($("#tfzd_end_date").val()!=""||$("#todoend_flag").val()=="Y"){
            if ($("#tfy_Arcase").val().Left(2) != "XX") {
                var astr="該案件已進行結案程序，如確定要交辦則需註記是否復案，請問是否復案？※復案後系統將自動取消結案流程並銷管結案期限。";
                if($("#tfzd_end_date").val()!=""){
                    astr = "該案件已結案，如確定要交辦則需註記是否復案，請問是否復案？※如有結案程序未完成，復案後系統將自動取消結案流程並銷管結案期限。";
                }
                var tback_flag=confirm(astr);
                $("#A9Z_back_flag").prop("checked",tback_flag);
                dmt_form.get_backdata("A9Z");
            }else{
                var tend_flag=confirm("該案件已結案，如確定要交辦則需註記是否結案，請問是否結案？");
                $("#A9Z_end_flag").prop("checked",tend_flag);
                dmt_form.get_backdata("A9Z");
            }
        }
        //申請人檢查
        chkdmtandtemp_ap(low_no,low_no1);

        $("#keyseq").val("Y");
        $("#btnseq_ok").lock();//舊案[查詢主案件編號]
        $("#DelayCase").show();//舊案
        $("#CaseNew,#CaseNewAssign").hide();//新案/新案(指定編號)

        $("input[name=fr4_remark3][value='"+oMain.vdmtall[0].dmt_temp_remark3+"']").prop("checked", true);
    }
}

//依案件母案編號抓案件資料並綁定
function delayNO1(low_no, low_no1) {
    if (low_no == "" || low_no1 == "" || !IsNumeric(low_no)) {
        alert("案件編號錯誤，請重新輸入");
        return false;
    }

    //取得案件資料
    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/jsonDelaySQL.aspx?delay_seq=" + low_no +
            "&delay_seq1=" + low_no1 + "&type=ref_no" +
            "&cust_area=" + $("#F_cust_area").val() + "&cust_seq=" + $("#F_cust_seq").val(),
        async: false,
        cache: false,
        success: function (json) {
            //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(delayNO1)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            toastr.info("<a href='" + this.url + "' target='_new'>Debug(delayNO1)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            oMain = $.parseJSON(json);
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });

    if (oMain.vdmtall.length == 0) {
        alert("無此案件編號");
        return false;
    } else {
        $("#dseqa_1,#dseqb_1").lock();
        $("#dseq1a_1,#dseq1b_1").lock();
        $("#btndseq_oka_1,#btndseq_okb_1").hide();//[確定]
        $("#dmseqb_1").val(low_no);
        $("#dmseq1b_1").val(low_no1);
        if (confirm("確定要依母案本所編號資料覆蓋嗎？") == false) {
            return false;
        }
        $("#tfzd_S_mark").val(oMain.vdmtall[0].s_mark);
        $("input[name='tfzy_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr2_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr21_S_mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr11_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr3_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr1_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr4_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fr_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='frf_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        $("input[name='fbf_S_Mark'][value='" + oMain.vdmtall[0].s_mark + "']").prop("checked", true);
        if (oMain.vdmtall[0].s_mark == "S") {
            $("#s_marka_1,#s_markb_1").val("92年修正前服務標章");
        } else if (oMain.vdmtall[0].s_mark == "N") {
            $("#s_marka_1,#s_markb_1").val("團體商標");
        } else if (oMain.vdmtall[0].s_mark == "M") {
            $("#s_marka_1,#s_markb_1").val("團體標章");
        } else if (oMain.vdmtall[0].s_mark == "L") {
            $("#s_marka_1,#s_markb_1").val("證明標章");
        } else {
            $("#s_marka_1,#s_markb_1").val("商標");
        }
        //正聯防
        $("#tfzy_Pul,#tfzd_Pul").val(oMain.vdmtall[0].pul).triggerHandler("change");
        $("#tfzd_Tcn_ref").val(oMain.vdmtall[0].tcn_ref);
        $("#tfzd_Tcn_Class").val(oMain.vdmtall[0].tcn_class);
        $("#tfzd_Tcn_name").val(oMain.vdmtall[0].tcn_name);
        $("#tfzd_Tcn_mark").val(oMain.vdmtall[0].tcn_mark);
        $("#tfzd_cust_prod").val(oMain.vdmtall[0].cust_prod);

        $("#tfzd_apply_no,#O_apply_no").val(oMain.vdmtall[0].apply_no);
        $("#tfzd_issue_no,#O_issue_no").val(oMain.vdmtall[0].issue_no);

        $("#tfzd_appl_name").val(oMain.vdmtall[0].appl_name);
        $("#new_no11,#fr1_apply_no,#fr_apply_no,#fbf_no").val(oMain.vdmtall[0].apply_no);//申請號數
        $("#apply_noa_1").val(oMain.vdmtall[0].apply_no);
        $("#ncname111,#ncname121,#appl_namea_1,#appl_nameb_1").val(oMain.vdmtall[0].appl_name);//商標/標章名稱
        $("#fr_appl_name,#fr1_appl_name,#fr2_appl_name,#fr3_appl_name,#fr4_appl_name,#frf_appl_name,#fbf_appl_name").val(oMain.vdmtall[0].appl_name);//商標/標章名稱
        $("#new_no21,#fr_issue_no,#fr1_issue_no,#fr2_issue_no,#fr3_issue_no,#fr4_issue_no,#issue_nob_1").val(oMain.vdmtall[0].issue_no);//註冊案號
        $("#draw_attach_file,#Draw_file").val(oMain.vdmtall[0].draw_file);//圖檔檢視
        $("#tft1_mod_count11,#tft2_mod_count2").val("1");//件數

        $("#tfzd_Oappl_name").val(oMain.vdmtall[0].oappl_name);//聲明不專用
        $("#tfzd_Cappl_name").val(oMain.vdmtall[0].cappl_name);//圖樣中文部份
        $("#tfzd_Eappl_name").val(oMain.vdmtall[0].eappl_name);//外文
        $("#tfzd_eappl_name1").val(oMain.vdmtall[0].eappl_name1);//中文字義
        $("#tfzd_eappl_name2").val(oMain.vdmtall[0].eappl_name2);//讀音
        $("#tfzd_Zname_type,#tfzy_Zname_type").val(oMain.vdmtall[0].zname_type);//語文別
        $("#tfzd_Draw").val(oMain.vdmtall[0].draw);//圖形描述
        $("#tfzd_Symbol").val(oMain.vdmtall[0].symbol);//記號說明
        //圖樣顏色
        if (oMain.vdmtall[0].color == "B") {
            $("#tfzy_colorB").prop("checked", true);//墨色
        } else if (oMain.vdmtall[0].color == "C" || oMain.vdmtall[0].color == "M") {
            $("#tfzy_colorC").prop("checked", true);//彩色
        } else {
            $("#tfzy_colorX").prop("checked", true);//無
        }
        $("#pfzd_prior_date").val(dateReviver(oMain.vdmtall[0].prior_date, "yyyy/M/d"));//優先權申請日
        $("#tfzy_prior_country,#tfzd_prior_country").val(oMain.vdmtall[0].prior_country);//優先權首次申請國家
        $("#tfzd_prior_no").val(oMain.vdmtall[0].prior_no);//優先權申請案號
        $("#tfzd_apply_date").val(dateReviver(oMain.vdmtall[0].apply_date, "yyyy/M/d"));//申請日期
        $("#tfzd_issue_date").val(dateReviver(oMain.vdmtall[0].issue_date, "yyyy/M/d"));//註冊日期
        $("#tfzd_open_date").val(dateReviver(oMain.vdmtall[0].open_date, "yyyy/M/d"));//公告日期
        $("#tfzd_rej_no,#O_rej_no").val(oMain.vdmtall[0].rej_no);//核駁號
        $("#tfzd_dmt_term1").val(dateReviver(oMain.vdmtall[0].term1, "yyyy/M/d"));//專用期限
        $("#tfzd_dmt_term2").val(dateReviver(oMain.vdmtall[0].term2, "yyyy/M/d"));//專用期限
        $("#tfzd_renewal").val(oMain.vdmtall[0].renewal);//延展次數

        $("#tfzr_class_count,#tft3_class_count2,#mod_count").val(oMain.vdmtall[0].class_count);//共N類
        $("#tfzr_class,#tft3_class2,#mod_dclass").val(oMain.vdmtall[0].class);//類別
        if (br_form.Add_classFC3) br_form.Add_classFC3(0);
        if (br_form.Add_classFL1) br_form.Add_classFL1(0);
        if (CInt($("#tfzr_class_count").val() == 0)) {
            dmt_form.Add_class(1);//類別預設顯示第1筆
            if (br_form.Add_classFC3) br_form.Add_classFC3(1);
            if (br_form.Add_classFL1) br_form.Add_classFL1(1);
        } else {
            if (oMain.dmt_good.length > 0) {
                dmt_form.Add_class(oMain.dmt_good.length);//產生筆數
                if (br_form.Add_classFC3) br_form.Add_classFC3(oMain.dmt_good.length);
                if (br_form.Add_classFL1) br_form.Add_classFL1(oMain.dmt_good.length);
                $.each(oMain.dmt_good, function (i, item) {
                    $("#class1_" + (i + 1)).val(item.class).lock();//第X類
                    $("#good_count1_" + (i + 1)).val(item.dmt_goodcount).lock();//共N項
                    $("#grp_code1_" + (i + 1)).val(item.dmt_grp_code).lock();//商品群組代碼
                    $("#good_name1_" + (i + 1)).val(item.dmt_goodname).lock();//商品名稱
                    //fc3
                    $("#class32_" + (i + 1)).val(item.class);//第X類
                    $("#good_name32_" + (i + 1)).val(item.dmt_goodname);//商品名稱
                    $("#good_count32_" + (i + 1)).val(item.dmt_goodcount);//共N項
                    //fl1
                    $("#new_no_" + (i + 1)).val(item.class);//第X類
                    $("#list_remark_" + (i + 1)).val(item.dmt_goodname);//共N商品名稱
                });
            }
            dmt_form.count_kind(1);//類別串接
            if (br_form.count_kindFC3) br_form.count_kindFC3(1);//fc3類別串接
            if (br_form.count_kindFL1) br_form.count_kindFL1(1);//fl1類別串接
        }

        var kclass_type = oMain.vdmtall[0].class_type;//案件主檔之類別種類
        var ks_mark2 = oMain.vdmtall[0].s_mark2;//案件主檔之商標種類
        $("input[name='tft3_class_type2'][value='" + kclass_type + "']").prop("checked", true);
        $("input[name='tfzr_class_type'][value='" + kclass_type + "']").prop("checked", true);
        $("input[name='tfzd_s_mark2'][value='" + ks_mark2 + "']").prop("checked", true);//商標種類2

        //展覽會優先權資料
        dmt_form.getshow("dmt_mseq");

        $("input[name=fr4_remark3][value='" + oMain.vdmtall[0].dmt_temp_remark3 + "']").prop("checked", true);
    }
}

//check申請人
function chkdmtandtemp_ap(pseq, pseq1) {
    var apcust_list = {};
    var dochk = true;
    var same_ap_flag = "N";
    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/json_get_dmt_ap.aspx?seq=" + pseq + "&seq1=" + pseq1,
        async: false,
        cache: false,
        success: function (json) {
            //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            apcust_list = $.parseJSON(json);
            if (apcust_list.length == 0) {
                alert("無該申請人編號!!!");
                dochk=false;
            }
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>check申請人失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: 'check申請人失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });

    if (dochk) {
        var left3 = $("#tfy_Arcase").val().Left(3);
        if (left3 == "FC0" || left3 == "FC2" || left3 == "FC6" || left3 == "FC8" || left3 == "FCC" || left3 == "FCD" || left3 == "FCG" || left3 == "FCI") {
            same_ap_flag = "N";
            $.each(apcust_list, function (x, item) {
                if ($("#FC0_apnum").val() == 0) {
                    getdmtap_FC0(pseq, pseq1);
                    return false;
                } else if (item.dmt_apcount != CInt($("#FC0_apnum").val())) {
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋⑴?")) {
                        getdmtap_FC0(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#FC0_apnum").val()) ; r++) {
                        if (item.apsqlno != $("#dbmn_apsqlno_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋⑵?")) {
                    getdmtap_FC0(pseq, pseq1);
                    return false;
                }
            }
        } else if (left3 == "FC1" || left3 == "FC5" || left3 == "FC7" || left3 == "FC9" || left3 == "FCA" || left3 == "FCB" || left3 == "FCF" || left3 == "FCH") {
            same_ap_flag = "N";
            $.each(apcust_list, function (x, item) {
                if ($("#apnum").val() == 0) {
                    getdmtap_FC1(pseq, pseq1);
                    return false;
                } else if (item.dmt_apcount != CInt($("#apnum").val())) {
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋⑶?")) {
                        getdmtap_FC1(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
                        if (item.apsqlno != $("#dbmn1_apsqlno_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋⑷?")) {
                    getdmtap_FC1(pseq, pseq1);
                    return false;
                }
            }
        } else if (left3 == "FC3" || left3 == "FC4") {
            same_ap_flag = "N";
            $.each(apcust_list, function (x, item) {
                if ($("#fc_apnum").val() == 0) {
                    getdmtap_FC(pseq, pseq1);
                    return false;
                } else if (item.dmt_apcount != CInt($("#fc_apnum").val())) {
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋⑸?")) {
                        getdmtap_FC(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#fc_apnum").val()) ; r++) {
                        if (item.apsqlno != $("#apsqlno_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋⑹?")) {
                    getdmtap_FC(pseq, pseq1);
                    return false;
                }
            }
        } else{
            same_ap_flag = "N";
            $.each(apcust_list, function (x, item) {
                if ($("#apnum").val() == 0) {
                    getdmtap(pseq, pseq1);
                    return false;
                } else if (item.dmt_apcount != CInt($("#apnum").val())) {
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋⑺?")) {
                        getdmtap(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
                        if (item.apsqlno != $("#apsqlno_" + r).val() || item.ap_cname1 != $("#ap_cname1_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋⑻?")) {
                    getdmtap(pseq, pseq1);
                    return false;
                }
            }
        }

    }
}

function getdmtap(pseq, pseq1){
    $("#tabap tbody").empty();
    $("#apnum").val("0");

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/json_get_dmt_ap.aspx?seq=" + pseq + "&seq1=" + pseq1,
        async: false,
        cache: false,
        success: function (json) {
            //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            var apcust_list = $.parseJSON(json);
            if (apcust_list.length == 0) {
                alert("案件無申請人!!!");
                return false;
            }

            $.each(apcust_list, function (i, item) {
                //增加一筆
                $("#AP_Add_button").click();
                //填資料
                var nRow = $("#apnum").val();
                $("#apsqlno_" + nRow).val(item.apsqlno);
                $("#apcust_no_" + nRow).val(item.apcust_no);
                $("#apclass_" + nRow).val(item.apclass);
                $("#ap_country_" + nRow).val(item.ap_country);
                $("#ap_cname1_" + nRow).val(item.ap_cname1);
                $("#ap_cname2_" + nRow).val(item.ap_cname2);
                $("#ap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
                $("#ap_ename1_" + nRow).val(item.ap_ename1);
                $("#ap_ename2_" + nRow).val(item.ap_ename2);
                $("#ap_ename_" + nRow).val(item.ap_ename1 + item.ap_ename2);
                $("#ap_crep_" + nRow).val(item.ap_crep);
                $("#ap_erep_" + nRow).val(item.ap_erep);
                $("#ap_zip_" + nRow).val(item.ap_zip);
                $("#ap_addr1_" + nRow).val(item.ap_addr1);
                $("#ap_addr2_" + nRow).val(item.ap_addr2);
                $("#ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                $("#ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                $("#ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                $("#ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                $("#apatt_zip_" + nRow).val(item.apatt_zip);
                $("#apatt_addr1_" + nRow).val(item.apatt_addr1);
                $("#apatt_addr2_" + nRow).val(item.apatt_addr2);
                $("#apatt_tel0_" + nRow).val(item.apatt_tel0);
                $("#apatt_tel_" + nRow).val(item.apatt_tel);
                $("#apatt_tel1_" + nRow).val(item.apatt_tel1);
                $("#apatt_fax_" + nRow).val(item.apatt_fax);
                if (item.Server_flag == "Y") {
                    $("#ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                } else {
                    $("#ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                }
                $("#ap_fcname_" + nRow).val(item.ap_fcname);
                $("#ap_lcname_" + nRow).val(item.ap_lcname);
                $("#ap_fename_" + nRow).val(item.ap_fename);
                $("#ap_lename_" + nRow).val(item.ap_lename);
                $("#ap_sql_" + nRow).val(item.ap_sql);
                //申請人序號空值不顯示
                if (item.ap_sql == "" || item.ap_sql == "0") {
                    $("#trap_sql_" + nRow).hide();
                }
            })
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
}

//FC3、FC4減縮註冊商品之案件申請人
function getdmtap_FC(pseq, pseq1){
    $("#FC_tabap tbody").empty();
    $("#FC_apnum").val("0");

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/json_get_dmt_ap.aspx?seq=" + pseq + "&seq1=" + pseq1,
        async: false,
        cache: false,
        success: function (json) {
            //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            var apcust_list = $.parseJSON(json);
            if (apcust_list.length == 0) {
                alert("案件無申請人!!!");
                return false;
            }

            $.each(apcust_list, function (i, item) {
                //增加一筆
                $("#FC_AP_Add_button").click();
                //填資料
                var nRow = $("#FC_apnum").val();
                $("#apsqlno_" + nRow).val(item.apsqlno);
                $("#apcust_no_" + nRow).val(item.apcust_no);
                $("#apclass_" + nRow).val(item.apclass);
                $("#ap_country_" + nRow).val(item.ap_country);
                $("#ap_cname1_" + nRow).val(item.ap_cname1);
                $("#ap_cname2_" + nRow).val(item.ap_cname2);
                $("#ap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
                $("#ap_ename1_" + nRow).val(item.ap_ename1);
                $("#ap_ename2_" + nRow).val(item.ap_ename2);
                $("#ap_ename_" + nRow).val(item.ap_ename1 + item.ap_ename2);
                $("#ap_crep_" + nRow).val(item.ap_crep);
                $("#ap_erep_" + nRow).val(item.ap_erep);
                $("#ap_zip_" + nRow).val(item.ap_zip);
                $("#ap_addr1_" + nRow).val(item.ap_addr1);
                $("#ap_addr2_" + nRow).val(item.ap_addr2);
                $("#ap_eaddr1_" + nRow).val(item.ap_eaddr1);
                $("#ap_eaddr2_" + nRow).val(item.ap_eaddr2);
                $("#ap_eaddr3_" + nRow).val(item.ap_eaddr3);
                $("#ap_eaddr4_" + nRow).val(item.ap_eaddr4);
                $("#apatt_zip_" + nRow).val(item.apatt_zip);
                $("#apatt_addr1_" + nRow).val(item.apatt_addr1);
                $("#apatt_addr2_" + nRow).val(item.apatt_addr2);
                $("#apatt_tel0_" + nRow).val(item.apatt_tel0);
                $("#apatt_tel_" + nRow).val(item.apatt_tel);
                $("#apatt_tel1_" + nRow).val(item.apatt_tel1);
                $("#apatt_fax_" + nRow).val(item.apatt_fax);
                if (item.Server_flag == "Y") {
                    $("#ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                } else {
                    $("#ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                }
                $("#ap_fcname_" + nRow).val(item.ap_fcname);
                $("#ap_lcname_" + nRow).val(item.ap_lcname);
                $("#ap_fename_" + nRow).val(item.ap_fename);
                $("#ap_lename_" + nRow).val(item.ap_lename);
                $("#ap_sql_" + nRow).val(item.ap_sql);
                //申請人序號空值不顯示
                if (item.ap_sql == "" || item.ap_sql == "0") {
                    $("#trap_sql_" + nRow).hide();
                }
            })
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
}

//FC0申請事項變更之案件申請人
function getdmtap_FC0(pseq, pseq1){
    $("#FC0_tabap tbody").empty();
    $("#FC0_apnum").val("0");

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/json_get_dmt_ap.aspx?seq=" + pseq + "&seq1=" + pseq1,
        async: false,
        cache: false,
        success: function (json) {
            //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            var apcust_list = $.parseJSON(json);
            if (apcust_list.length == 0) {
                alert("案件無申請人!!!");
                return false;
            }

            $.each(apcust_list, function (i, item) {
                //增加一筆
                $("#FC0_AP_Add_button").click();
                //填資料
                var nRow = $("#FC0_apnum").val();
                $("#dbmn_apsqlno_" + nRow).val(item.apsqlno);
                $("#dbmn_apcust_no_" + nRow).val(item.apcust_no);
                $("#ttg2_apclass_" + nRow).val(item.apclass);
                $("#dbmn_ncname1_" + nRow).val(item.ap_cname1);
                $("#dbmn_ncname2_" + nRow).val(item.ap_cname2);
                $("#dbmn_nename1_" + nRow).val(item.ap_ename1);
                $("#dbmn_nename2_" + nRow).val(item.ap_ename2);
                $("#dbmn_ncrep_" + nRow).val(item.ap_crep);
                $("#dbmn_nerep_" + nRow).val(item.ap_erep);
                $("#dbmn_nzip_" + nRow).val(item.ap_zip);
                $("#dbmn_naddr1_" + nRow).val(item.ap_addr1);
                $("#dbmn_naddr2_" + nRow).val(item.ap_addr2);
                $("#dbmn_neaddr1_" + nRow).val(item.ap_eaddr1);
                $("#dbmn_neaddr2_" + nRow).val(item.ap_eaddr2);
                $("#dbmn_neaddr3_" + nRow).val(item.ap_eaddr3);
                $("#dbmn_neaddr4_" + nRow).val(item.ap_eaddr4);
                if (item.Server_flag == "Y") {
                    $("#fc0_ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                } else {
                    $("#fc0_ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                }
                $("#dbmn_fcname_" + nRow).val(item.ap_fcname);
                $("#dbmn_lcname_" + nRow).val(item.ap_lcname);
                $("#dbmn_fename_" + nRow).val(item.ap_fename);
                $("#dbmn_lename_" + nRow).val(item.ap_lename);
            })
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
}

//FC1申請事項變更之案件申請人
function getdmtap_FC1(pseq, pseq1) {
    $("#FC2_tabap tbody").empty();
    $("#FC2_apnum").val("0");

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/json_get_dmt_ap.aspx?seq=" + pseq + "&seq1=" + pseq1,
        async: false,
        cache: false,
        success: function (json) {
            //if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_apcust交辦申請人)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            var apcust_list = $.parseJSON(json);
            if (apcust_list.length == 0) {
                alert("案件無申請人!!!");
                return false;
            }

            $.each(apcust_list, function (i, item) {
                //增加一筆
                $("#FC2_AP_Add_button").click();
                //填資料
                var nRow = $("#FC0_apnum").val();
                $("#dbmn1_apsqlno_" + nRow).val(item.apsqlno);
                $("#dbmn1_apcust_no_" + nRow).val(item.apcust_no);
                $("#ttg1_apclass_" + nRow).val(item.apclass);
                $("#dbmn1_country_" + nRow).val(item.ap_country);
                $("#dbmn1_ncname1_" + nRow).val(item.ap_cname1);
                $("#dbmn1_ncname2_" + nRow).val(item.ap_cname2);
                $("#dbmn1_ap_cname_" + nRow).val(item.ap_cname1 + item.ap_cname2);
                $("#dbmn1_nename1_" + nRow).val(item.ap_ename1);
                $("#dbmn1_nename2_" + nRow).val(item.ap_ename2);
                $("#dbmn1_ap_ename_" + nRow).val(item.ap_ename1 + item.ap_ename2);
                $("#dbmn1_ncrep_" + nRow).val(item.ap_crep);
                $("#dbmn1_nerep_" + nRow).val(item.ap_erep);
                $("#dbmn1_nzip_" + nRow).val(item.ap_zip);
                $("#dbmn1_naddr1_" + nRow).val(item.ap_addr1);
                $("#dbmn1_naddr2_" + nRow).val(item.ap_addr2);
                $("#dbmn1_neaddr1_" + nRow).val(item.ap_eaddr1);
                $("#dbmn1_neaddr2_" + nRow).val(item.ap_eaddr2);
                $("#dbmn1_neaddr3_" + nRow).val(item.ap_eaddr3);
                $("#dbmn1_neaddr4_" + nRow).val(item.ap_eaddr4);
                $("#dbmn1_ntel0_" + nRow).val(item.apatt_tel0);
                $("#dbmn1_ntel_" + nRow).val(item.apatt_tel);
                $("#dbmn1_ntel1_" + nRow).val(item.apatt_tel1);
                $("#dbmn1_nfax_" + nRow).val(item.apatt_fax);
                $("#dbmn1_fcname_" + nRow).val(item.ap_fcname);
                $("#dbmn1_lcname_" + nRow).val(item.ap_lcname);
                $("#dbmn1_fename_" + nRow).val(item.ap_fename);
                $("#dbmn1_lename_" + nRow).val(item.ap_lename);
                if (item.Server_flag == "Y") {
                    $("#ap_hserver_flag_" + nRow).prop("checked", true).triggerHandler("click");
                } else {
                    $("#ap_hserver_flag_" + nRow).prop("checked", false).triggerHandler("click");
                }
            })
        },
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
}

//2011/2/11因結案進行中要進行復案，檢查有無結案進行中,若有修改要一併修改oldcase_dataA4.inc
function chkseqdata(low_no, low_no1) {
    $("#todoend_flag").val("N");
    var searchSql = "SELECT count(*) as cnt from todo_dmt where seq= " + low_no + " and seq1='" + low_no1 + "' and job_status='NN' and dowhat in ('DC_END1','ACC_END','DB_END','DC_END2') ";
    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
        data: { sql: searchSql },
        async: false,
        cache: false,
        success: function (json) {
            var JSONdata = $.parseJSON(json);
            if (JSONdata.length > 0) {
                if (JSONdata[0].cnt > 0) {
                    $("#todoend_flag").val("Y");
                }
            }
        },
        error: function (xhr) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({ title: '檢查有無結案進行中失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
}

//2018/11/12檢查有無債信不良,若有修改要一併修改Oldcase_DataA4.inc
function chkcustdata(low_no, low_no1) {
    var chkflag = true;

    searchSql = "select d.rmark_code from dmt a ";
    searchSql += "INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
    searchSql += "where seq=" + low_no + " and seq1='" + low_no1 + "' ";

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
        data: { sql: searchSql },
        async: false,
        cache: false,
        success: function (json) {
            var JSONdata = $.parseJSON(json);
            if (JSONdata.length > 0) {
                if (JSONdata[0].rmark_code.Left(2)=="E2") {
                    chkflag=false
                }
            }
        },
        error: function (xhr) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({ title: '檢查有無結案進行中失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
    return chkflag;
}
