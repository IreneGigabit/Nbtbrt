main.savechk = function () {
    //�Ȥ��p���H�ˬd
    if (main.chkCustAtt() == false) return false;
	
    //�ӽФH�ˬd
    if (main.chkApp() == false) return false;

    //����榡�ˬd,��class=dateField,����J�h�ˬd
    if (main.chkDate("#case") == false) { alert("����榡���~,���ˬd"); return false; }
    if (main.chkDate("#dmt") == false) { alert("����榡���~,���ˬd"); return false; }
    if (main.chkDate("#tran") == false) { alert("����榡���~,���ˬd"); return false; }
	
    //�ӼЦW���ˬd
    if (main.chkApplName() == false) return false;

    //��������ˬd
    if (main.chkRequire() == false) return false;

    //�������e�����ˬd
    if (main.chkCaseForm() == false) return false;

    //�s/�®׸�
    if (main.chkNewOld() == false) return false;

    //�X�W�N�z�H�ˬd
    if (main.chkAgt("apnum", "apclass", "tfzd_agt_no") == false) return false;

    //���״_���ˬd
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
	
    //�D�ɰӫ~���O�ˬd
    if (main.chkGood() == false) return false;

    //���w���O�ˬd
    if ($("#tfzd_class_count").val() != "") {
        //2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
        if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
            if ($("input[name='tfzd_class_type']:checked").length == 0) {
                alert("���I�����O����(��ڤ���������)�I�I");
                settab("#tran");
                $("input[name=tfzd_class_type]").eq(0).focus();
                return false;
            }
            var inputCount = 0;
            for (var j = 1; j <= CInt($("#num2").val()); j++) {
                if ($("#good_name2_" + j).val() != "" && $("#class2_" + j).val() == "") {
                    //����J�ӫ~�W��,���S��J���O
                    alert("�п�J���O!");
                    settab("#tran");
                    $("#class2_" + j).focus();
                    return false;
                }
                if (br_form.checkclass(j) == false) {//�ˬd���O�d��0~45
                    $("#class2_" + j).focus();
                    settab("#tran");
                    return false;
                }
                if ($("#class2_" + j).val() != "") {
                    inputCount++;//��ڦ���J�~�n+
                }
            }
        }
        //�ˬd���w���O���L����
        var objClass = {};
        for (var r = 1; r <= CInt($("#num2").val()); r++) {
            var lineTa = $("#class2_" + r).val();
            if (lineTa != "" && objClass[lineTa]) {
                alert("�ӫ~���O����,�Э��s��J!!!");
                $("#class2_" + r).focus();
                return false;
            } else {
                objClass[lineTa] = { flag: true, idx: r };
            }
        }
        $("#ctrlcount2").val(inputCount == 0 ? "" : inputCount);
        if (CInt($("#tfzd_class_count").val()) != CInt($("#num2").val())) {
            var answer = "���w�ϥΰӫ~���O����(�@ " + CInt($("#tfzd_class_count").val()) + " ��)�P��J���w�ϥΰӫ~(�@ " + CInt($("#num2").val()) + " ��)���šA\n�O�_�T�w���w�ϥΰӫ~�@ " + CInt($("#num2").val()) + " ���H";
            if (answer) {
                $("#tfzd_class_count").val($("#num2").val());
            } else {
                settab("#tran");
                $("#tfzd_class_count").focus();
                return false;
            }
        }
    }

    //�ܧ󶵥�
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

    //�ˬd�j���׽дڵ��O�ˬd&����
    if (main.chkAr() == false) return false;

    //�����ˬd
    if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
        if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
            settab("#tran");
            $("#O_item1").focus();
            return false;
        }
    }

    //20161006�W�[�Ƶ��ˬd(�]���q�l�e��ק�Ƶ�.2�泣�i�s��)
    if ($("#O_item1").val() != "" && $("input[name=O_item2]").prop("checked").length > 0 && $("input[name=O_item]").eq(0).prop("checked") == false) {
        alert("�Ƶ�����(1)���Ŀ�A���ˬd");
        return false;
    }
    if ($("#O_item1").val() != "" && $("input[name=O_item2]").prop("checked").length > 0 && $("input[name=O_item]").eq(1).prop("checked") == false) {
        alert("�Ƶ�����(2)���Ŀ�A���ˬd");
        return false;
    }
    
    //�ˬd���i�Ӽ��v�d��Τ��e
    if ($("#tfzd_class_count").val() != "" && $("#tfgp_tran_remark2").val() != "") {
        alert("���i�ӫ~�A�ȦW�١B�ҩ��Ъ��Τ��e�B�����´�η|�����|�y�u���J�@���A�н��ˬd");
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
