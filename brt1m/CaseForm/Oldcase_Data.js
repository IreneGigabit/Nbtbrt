//依案件編號抓案件資料並綁定
function delayNO(){
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
            $("#dialog").dialog({ title: 'check申請人失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>check申請人失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
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
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋?")) {
                        getdmtap_FC0(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#FC0_apnum").val()) ; r++) {
                        if (item.dmt_apcount != $("#dbmn_apsqlno_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋?")) {
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
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋?")) {
                        getdmtap_FC1(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
                        if (item.dmt_apcount != $("#dbmn1_apsqlno_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋?")) {
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
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋?")) {
                        getdmtap_FC(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#fc_apnum").val()) ; r++) {
                        if (item.dmt_apcount != $("#apsqlno_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋?")) {
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
                    if (confirm("輸入的申請人數與案件主檔申請人數不同，是否依案件主檔申請人資料覆蓋?")) {
                        getdmtap(pseq, pseq1);
                        return false;
                    }
                } else {
                    for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
                        if (item.dmt_apcount != $("#apsqlno_" + r).val() || item.ap_cname1 != $("#ap_cname1_" + r).val()) {
                            same_ap_flag = "Y";
                            break;
                        }
                    }
                }
            });

            if (same_ap_flag == "Y") {
                if (confirm("輸入的申請人與案件主檔申請人不同，是否依案件主檔申請人資料覆蓋?")) {
                    getdmtap(pseq, pseq1);
                    return false;
                }
            }
        }

    }
}

function getdmtap(pseq, pseq1){
    $("#tabap tbody").empty();

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
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
        }
    });
}

//FC3、FC4減縮註冊商品之案件申請人
function getdmtap_FC(pseq, pseq1){
    $("#FC_tabap tbody").empty();

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
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
        }
    });
}

//FC0申請事項變更之案件申請人
function getdmtap_FC0(pseq, pseq1){
    $("#FC0_tabap tbody").empty();

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
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
        }
    });
}

//FC1申請事項變更之案件申請人
function getdmtap_FC1(pseq, pseq1) {
    $("#FC1_tabap tbody").empty();

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
            $("#dialog").dialog({ title: '案件申請人資料載入失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>案件申請人資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
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
            $("#dialog").dialog({ title: '檢查有無結案進行中失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>檢查有無結案進行中失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
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
            $("#dialog").dialog({ title: '檢查有無結案進行中失敗！', modal: true, maxHeight: 500, width: 800 });
            //toastr.error("<a href='" + this.url + "' target='_new'>檢查有無結案進行中失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
        }
    });
    return chkflag;
}
