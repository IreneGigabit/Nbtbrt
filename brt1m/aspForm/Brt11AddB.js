main.savechkB = function () {
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

	//****�Ƶ����
	switch ($("#tfy_Arcase").val().Left(3)) {
		case "DR1":
			$("#tfzd_appl_name").val($("#fr1_appl_name").val());
			$("#tfzd_issue_no").val($("#fr1_issue_no").val());
			//�j���׽дڵ��O�ˬd.�дڵ��O:�j���i�f��
			if ($("#tfp1_seq1").val() == "M" && $("#tfy_ar_mark").val() != "X") {
				alert("���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!");
				settab("#case");
				$("#tfy_ar_mark").focus();
				return false;
			} else if ($("#tfp1_seq1").val() != "M" && $("#tfy_ar_mark").val() == "X") {
				alert("�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!");
				settab("#tran");
				$("#tfp1_seq1").focus();
				return false;
			}
			if ($("#R_O_item1").val() != "" || $("#R_O_item2").val() != "" || $("#R_O_item3").val() != "") {
				$("#tfz1_other_item").val($("#R_O_item1").val() + ";" + $("#R_O_item2").val() + ";" + $("#R_O_item3").val());
			}
			if ($("#ttg11_mod_pul_new_no").val() != "" || $("#ttg11_mod_pul_ncname1").val() != "") {
				if ($("input[name='ttg11_mod_pul_mod_type']:checked").length == 0) {
					alert("��" + $("#ttg11_mod_pul_new_no").val() + "���u" + $("#ttg11_mod_pul_ncname1").val() + "�v����J��ơA�п�ܰӼЩμг��A�p����ܡA�бN��J��ƲM�šI");
					settab("#tran");
					$("input[name='ttg11_mod_pul_mod_type']:eq(0)").focus();
					return false;
				}
			}
			if ($("#ttg13_mod_pul_new_no").val() != "" || $("#ttg13_mod_pul_mod_dclass").val() != "") {
				if ($("#ttg13_mod_pul_mod_type").prop("checked") == false) {
					alert("���w�ϥΩ�ӼЪk�I��ӫh��" + $("#ttg13_mod_pul_new_no").val() + "����" + $("#ttg13_mod_pul_mod_dclass").val() + "���ӫ~���A�Ȥ����U�����o���J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI");
					settab("#tran");
					$("#ttg13_mod_pul_mod_type").focus();
					return false;
				}
			}
			if ($("#ttg14_mod_pul_new_no").val() != "" || $("#ttg14_mod_pul_mod_dclass").val() != "" || $("#ttg14_mod_pul_ncname1").val() != "") {
				if ($("#ttg14_mod_pul_mod_type").prop("checked") == false) {
					alert("���w�ϥΩ�ӼЪk�I��ӫh��" + $("#ttg14_mod_pul_new_no").val() + "����" + $("#ttg14_mod_pul_mod_dclass").val() + "��" + $("#ttg14_mod_pul_ncname1").val() + "�ӫ~���A�Ȥ��Ӽ��v�����o���J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI");
					settab("#tran");
					$("#ttg14_mod_pul_mod_type").focus();
					return false;
				}
			}
			//�X�W�N�z�H�ˬd
			if (main.chkAgt("apnum", "apclass", "tfp1_agt_no") == false) return false;
			
			//2012/10/3�W�[�o��ӼХ]�t�����A�]2012/7/1�s�ӽЮѭק�
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
					alert("�ץ�s�����o���ťաA�Э��s��J");
					settab("#tran");
					$("#tfp1_New_Ass_seq").focus();
					return false;
				}
				if (IsEmpty($("#tfp1_New_Ass_seq1").val())) {
					alert("�ץ�s���ƽX���o���ťաA�Э��s��J");
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
				alert("���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!");
				settab("#case");
				$("#tfy_ar_mark").focus();
				return false;
			} else if ($("#tfp2_seq1").val() != "M" && $("#tfy_ar_mark").val() == "X") {
				alert("�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!");
				settab("#tran");
				$("#tfp2_seq1").focus();
				return false;
			}
			if ($("#O_O_item1").val() != "" || $("#O_O_item2").val() != "" || $("#O_O_item3").val() != "") {
				$("#tfz2_other_item").val($("#O_O_item1").val() + ";" + $("#O_O_item2").val() + ";" + $("#O_O_item3").val());
			}
			if ($("#ttg21_mod_pul_new_no").val() != "" || $("#ttg21_mod_pul_ncname1").val() != "") {
				if ($("input[name='ttg21_mod_pul_mod_type']:checked").length == 0) {
					alert("��" + $("#ttg21_mod_pul_new_no").val() + "���u" + $("#ttg21_mod_pul_ncname1").val() + "�v����J��ơA�п�ܰӼЩμг��A�p����ܡA�бN��J��ƲM�šI");
					settab("#tran");
					$("input[name='ttg21_mod_pul_mod_type']:eq(0)").focus();
					return false;
				}
			}
			if ($("#ttg23_mod_pul_new_no").val() != "" || $("#ttg23_mod_pul_mod_dclass").val() != "") {
				if ($("#ttg13_mod_pul_mod_type").prop("checked") == false) {
					alert("���w�ϥΩ�ӼЪk�I��ӫh��" + $("#ttg23_mod_pul_new_no").val() + "����" + $("#ttg23_mod_pul_mod_dclass").val() + "���ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI");
					settab("#tran");
					$("#ttg23_mod_pul_mod_type").focus();
					return false;
				}
			}
			if ($("#ttg24_mod_pul_new_no").val() != "" || $("#ttg24_mod_pul_mod_dclass").val() != "" || $("#ttg24_mod_pul_ncname1").val() != "") {
				if ($("#ttg24_mod_pul_mod_type").prop("checked") == false) {
					alert("���w�ϥΩ�ӼЪk�I��ӫh��" + $("#ttg24_mod_pul_new_no").val() + "����" + $("#ttg24_mod_pul_mod_dclass").val() + "��" + $("#ttg24_mod_pul_ncname1").val() + "�ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI");
					settab("#tran");
					$("#ttg24_mod_pul_mod_type").focus();
					return false;
				}
			}
			//�X�W�N�z�H�ˬd
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
					alert("�ץ�s�����o���ťաA�Э��s��J");
					settab("#tran");
					$("#tfp2_New_Ass_seq").focus();
					return false;
				}
				if (IsEmpty($("#tfp2_New_Ass_seq1").val())) {
					alert("�ץ�s���ƽX���o���ťաA�Э��s��J");
					settab("#tran");
					$("#tfp2_New_Ass_seq1").focus();
					return false;
				}
			}
			break;
		case "DI1":
			$("#tfzd_appl_name").val($("#fr3_appl_name").val());
			$("#tfzd_issue_no").val($("#fr3_issue_no").val());
			//�j���׽дڵ��O�ˬd.�дڵ��O:�j���i�f��
			if ($("#tfp3_seq1").val() == "M" && $("#tfy_ar_mark").val() != "X") {
				alert("���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!");
				settab("#case");
				$("#tfy_ar_mark").focus();
				return false;
			} else if ($("#tfp3_seq1").val() != "M" && $("#tfy_ar_mark").val() == "X") {
				alert("�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!");
				settab("#tran");
				$("#tfp3_seq1").focus();
				return false;
			}
			if ($("#I_O_item1").val() != "" || $("#I_O_item2").val() != "" || $("#I_O_item3").val() != "") {
				$("#tfz3_other_item").val($("#I_O_item1").val() + ";" + $("#I_O_item2").val() + ";" + $("#I_O_item3").val());
			}
			if ($("#ttg31_mod_pul_new_no").val() != "" || $("#ttg31_mod_pul_ncname1").val() != "") {
				if ($("input[name='ttg31_mod_pul_mod_type']:checked").length == 0) {
					alert("��" + $("#ttg31_mod_pul_new_no").val() + "���u" + $("#ttg31_mod_pul_ncname1").val() + "�v����J��ơA�п�ܰӼЩμг��A�p����ܡA�бN��J��ƲM�šI");
					settab("#tran");
					$("input[name='ttg31_mod_pul_mod_type']:eq(0)").focus();
					return false;
				}
			}
			if ($("#ttg33_mod_pul_new_no").val() != "" || $("#ttg33_mod_pul_mod_dclass").val() != "") {
				if ($("#ttg33_mod_pul_mod_type").prop("checked") == false) {
					alert("���w�ϥΩ�ӼЪk�I��ӫh��" + $("#ttg33_mod_pul_new_no").val() + "����" + $("#ttg33_mod_pul_mod_dclass").val() + "���ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI");
					settab("#tran");
					$("#ttg33_mod_pul_mod_type").focus();
					return false;
				}
			}
	
			if ($("#ttg34_mod_pul_new_no").val() != "" || $("#ttg34_mod_pul_mod_dclass").val() != "" || $("#ttg34_mod_pul_ncname1").val() != "") {
				if ($("#ttg34_mod_pul_mod_type").prop("checked") == false) {
					alert("���w�ϥΩ�ӼЪk�I��ӫh��" + $("#ttg34_mod_pul_new_no").val() + "����" + $("#ttg34_mod_pul_mod_dclass").val() + "��" + $("#ttg34_mod_pul_ncname1").val() + "�ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI");
					settab("#tran");
					$("#ttg34_mod_pul_mod_type").focus();
					return false;
				}
			}
			//�X�W�N�z�H�ˬd
			if (main.chkAgt("apnum", "apclass", "tfp3_agt_no") == false) return false;

			//2012/10/3�W�[�o��ӼХ]�t�����A�]2012/7/1�s�ӽЮѭק�
			$("#tfzd_Cappl_name").val($("input[name='I_cappl_name']:checked").val() || "");
			$("#tfzd_eappl_name").val($("input[name='I_eappl_name']:checked").val() || "");
			$("#tfzd_jappl_name").val($("input[name='I_jappl_name']:checked").val() || "");
			$("#tfzd_Draw").val($("input[name='I_draw']:checked").val() || "");
			$("#tfzd_zappl_name1").val($("input[name='I_zappl_name1']:checked").val() || "");
			$("#tfzd_remark3").val($("input[name='I_remark3']:checked").val() || "");
				
			if ($("input[name='I_item1']:checked").length > 0) {
				//2013/1/24�]���ӼЪk�ץ��אּ�h��
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
					alert("�ץ�s�����o���ťաA�Э��s��J");
					settab("#tran");
					$("#tfp3_New_Ass_seq").focus();
					return false;
				}
				if (IsEmpty($("#tfp3_New_Ass_seq1").val())) {
					alert("�ץ�s���ƽX���o���ťաA�Э��s��J");
					settab("#tran");
					$("#tfp3_New_Ass_seq1").focus();
					return false;
				}
			}
			break;
		default:
			//�s/�®׸�
			if (main.chkNewOld() == false) return false;
			//�j���׽дڵ��O�ˬd
			if ($("#tfzb_seq1").val() == "M" && $("#tfy_Ar_mark").val() != "X") {
				alert("���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!");
				settab("#case");
				$("#tfy_Ar_mark").focus();
				return false;
			} else if ($("#tfzb_seq1").val() != "M" && $("#tfy_Ar_mark").val() == "X") {
				alert("�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!");
				settab("#tran");
				if ($("#tfy_case_stat").val() == "NN") {
					$("#New_seq1").focus();
				} else if ($("#tfy_case_stat").val() == "OO") {
					$("#old_seq1").focus();
				}
				return false;
			}
			if ($("#tfy_Arcase").val().Left(3) != "DE1" && $("#tfy_Arcase").val().Left(3) != "DE2") {
				//�X�W�N�z�H�ˬd
				if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;
			}
			break;
	}

	//�ץ󤺮e
	if ($("#tfy_Arcase").val().Left(3) == "DE1") {
		if ($("input[name='fr4_remark3']:checked").length = 0) {
			alert("�п�J�ӽ��|��ť�Ҥ��ץ����!!");
			settab("#tran");
			$("input[name='fr4_remark3']:eq(0)").focus();
			return false
		} else {
			$("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
		
		}

		if ($("input[name='fr4_Mark']:checked").length = 0) {
			alert("�п�J�ӽФH����!!");
			settab("#tran");
			$("input[name='fr4_Mark']:eq(0)").focus();
			return false
		} else {
			$("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
		}

		if ($("input[name=fr4_tran_mark]").prop("checked").length == 0) {
			alert("�п�J��ӷ�ƤH����!!");
			settab("#tran");
			$("input[name='fr4_tran_mark']").eq(0).focus();
			return false;
		}

		if (CInt($("#DE1_apnum").val()) == 0) {
			alert("�п�J��ӷ�ƤH��ơI");
			settab("#tran");
			return false;
		}
		for (var k = 1; k <= CInt($("#DE1_apnum").val()); k++) {
			if ($("#tfr4_ncname1_" + k).val() == "") {
				alert("�п�J��ӷ�ƤH�W��!!");
				settab("#tran");
				return false;
			}
		}
		if ($("#fr4_tran_remark1").val() == "") {
			alert("�п�J���|��ť�Ҥ��z��!!");
			settab("#tran");
			$("#fr4_tran_remark1").focus();
			return false;
		}
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "DE2") {
		if ($("input[name=fr4_remark3]").prop("checked").length == 0) {
			alert("�п�J�ӽ��|��ť�Ҥ��ץ����!!");
			settab("#tran");
			$("input[name='fr4_remark3']").eq(0).focus();
			return false;
		} else {
			$("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
		}

		if ($("input[name=fr4_Mark]").prop("checked").length == 0) {
			alert("�п�J�ӽФH����!!");
			settab("#tran");
			$("input[name='fr4_Mark']").eq(0).focus();
			return false;
		} else {
			$("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
		}

		if ($("#fr4_tran_remark1").val() == "") {
			alert("�п�J�s���Ҥγ��z�N����!!");
			settab("#tran");
			$("#fr4_tran_remark1").focus();
			return false;
		}
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
	}

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
	$("#tfzd_Pul").val($("#tfzy_Pul").val());
	$("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
	$("#tfzd_prior_country").val($("#tfzy_prior_country").val());

	//2010/10/4��ĳ�B���w�μo��W�[�O�����O�A�����ˬd���O�Ψ�ӫ~��ơA�����ˬd���O�ƻP��J�O�����ƬO�_�ۦP
	if ($("#tfy_Arcase").val().Left(3) == "DO1" || $("#tfy_Arcase").val().Left(3) == "DI1" || $("#tfy_Arcase").val().Left(3) == "DR1") {
		//2010/10/8���O�ˬd�A�ܤֿ�J�@��
		var sclass_count = 1;//���O�з����O�ơA��ǭ�=1
		var pname = "";
		switch ($("#tfy_Arcase").val().Left(3)) {
			case "DR1":
				pname = "fr1_class";
				for (var r = 1; r <= CInt($("#TaCount").val()); r++) {
					if ($("#nfyi_item_Arcase_" + r).val() == "DR1B") {
						sclass_count += CInt($("#nfyi_item_count_" + r).val());
						break;
					}
				}
				break;
			case "DO1":
				pname = "fr2_class";
				for (var r = 1; r <= CInt($("#TaCount").val()); r++) {
					if ($("#nfyi_item_Arcase_" + r).val() == "DO1B") {
						sclass_count += CInt($("#nfyi_item_count_" + r).val());
						break;
					}
				}
				break;
			case "DI1":
				pname = "fr3_class";
				for (var r = 1; r <= CInt($("#TaCount").val()); r++) {
					if ($("#nfyi_item_Arcase_" + r).val() == "DI1B") {
						sclass_count += CInt($("#nfyi_item_count_" + r).val());
						break;
					}
				}
				break;
		}
		if ($("#" + pname).val() == "") {
			alert("�п�J���O��ơI");
			settab("#tran");
			$("#" + pname).focus();
			return false;
		}
		var pclass_count = $("#" + pname + "_count").val();
		if (CInt(pclass_count) != sclass_count) {
			alert("���O���C���O��(�@" + sclass_count + "��)�P��줺�e���O��(�@" + pclass_count + "��)���P�A���ˬd�I");
			settab("#case");
			return false;
		}
	} else {
		//�D�ɰӫ~���O�ˬd
		if (main.chkGood() == false) return false;
	}

	//�ˬd�j���׽дڵ��O�ˬd&����
	if (main.chkAr() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfg1_seq").val($("#tfzb_seq").val());
	$("#tfg1_seq1").val($("#tfzb_seq1").val());

	return true;
}