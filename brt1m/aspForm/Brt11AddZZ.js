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

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
	$("#tfzd_Pul").val($("#tfzy_Pul").val());
	$("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
	$("#tfzd_prior_country").val($("#tfzy_prior_country").val());
	
	//�D�ɰӫ~���O�ˬd
	if (main.chkGood() == false) return false;

	//�ˬd�j���׽дڵ��O�ˬd&����
	if (main.chkAr() == false) return false;

	//*****�ץ󤺮e
	if ($("#tfy_Arcase").val().Left(3) == "FOB") {
		if ($("#tfg1_other_item").val() == "") {
			alert("�v�L���e�S���Ŀ�A�п�J!!");
			settab("#tran");
			$("#ttz1_P1").focus();
			return false;
		}
		$("#tfzd_mark").val($("input[name='fr_Mark']:checked").val() || "");
	}
	if ($("#tfy_Arcase").val().Left(3) == "AD7") {
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
	} else if ($("#tfy_Arcase").val().Left(3) == "AD8") {
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
	}
	//�ӽаh�O�ˬd
	if ($("#tfy_Arcase").val().Left(3) == "FOF") {
		if ($("#tfzf_other_item").val() == "") {
			alert("�п�J��w�䲼���Y�W�١I�I");
			settab("#tran");
			$("#tfzf_other_item").focus();
			return false;
		}
		if ($("#tfzf_debit_money").val() == "") {
			alert("�п�J�h�O���B�I�I");
			settab("#tran");
			$("#tfzf_debit_money").focus();
			return false;
		} else {
			if (IsNumeric($("#tfzf_debit_money").val()) == false) {
				alert("�h�O���B�������ƭȡA�Э��s��J�I�I");
				settab("#tran");
				$("#tfzf_debit_money").focus();
				return false;
			}
		}
		if ($("#tfzf_other_item1").val() == "") {
			alert("�п�J�W�O���ڸ��X�I�I");
			settab("#tran");
			$("#tfzf_other_item1").focus();
			return false;
		}
		if ($("#tfzf_other_item2").val() == "") {
			//20190613�W�[ �v��C�i����J�h�O��r��
			if ((main.right & 256) != 0) {
				alert("�п�J�����q���h�O��r���I�I");
				settab("#tran");
				$("input[name='ttzf_F1']:eq(0)").focus();
				return false;
			}
		} else {
			if ($("input[name='ttzf_F1']:eq(0)").prop("checked") == true) {
				if ($("#F1_yy").val() == "" || $("#F1_word").val() == "" || $("#F1_no").val() == "") {
					alert("�п�J�����q���h�O��r���I�I");
					settab("#tran");
					$("#F1_yy").focus();
					return false;
				}
			}
			if ($("input[name='ttzf_F1']:eq(1)").prop("checked") == true) {
				if ($("#F2_yy").val() == "" || $("#F2_word").val() == "" || $("#F2_no").val() == "") {
					alert("�п�J�����q���h�O��r���I�I");
					settab("#tran");
					$("#F2_yy").focus();
					return false;
				}
			}
		}
		$("#tfzd_mark").val($("input[name='frf_mark']:checked").val() || "");
	}
	//�ӽиɰe����ˬd
	if ($("#tfy_Arcase").val().Left(3) == "FB7") {
		if ($("#tfb7_other_item").val() == "") {
			alert("�ФĿ�ɰe���I");
			return false;
		}
	}

	//�ӽкM�^�ӽ��ˬd
	if ($("#tfy_Arcase").val().Left(3) == "FW1") {
		if ($("#tfw1_mod_claim1").prop("checked") == false) {
			alert("�ФĿ�u���ӽЮצ۽кM�^�v");
			return false;
		}
	}

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfg1_seq").val($("#tfzb_seq").val());
	$("#tfg1_seq1").val($("#tfzb_seq1").val());

	if ($("#tfy_Arcase").val().Left(3) == "FOB") {
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfg2_agt_no1") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "AD7" || $("#tfy_Arcase").val().Left(3) == "AD8") {
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "FOF") {
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfzf_agt_no1") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "FB7") {
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfb7_agt_no1") == false) return false;
	} else {
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;
	}
 
	//reg.action="Brt11AddZZ.asp"	
	//$("#submittask").val("Add");
	//If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	//reg.Submit
}