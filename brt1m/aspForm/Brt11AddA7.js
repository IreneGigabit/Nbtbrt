main.savechkA7 = function () {
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
	var errName = "", errName1 = "";
	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		errName = "���v�_��";
		errName1 = "���v����";
	} else {
		errName = "�פ���";
	}
	if ($("#tfg1_term1").val() == "") {
		if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
			|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
		) {
			if ($("input[name='tfg1_mod_claim1']").eq(0).prop("checked") == true) {
				alert(errName + "���o���ť�,�Э��s��J!!");
				settab("#tran");
				$("#tfg1_term1").focus();
				return false;
			}
		} else {
			alert(errName + "���o���ť�,�Э��s��J!!");
			settab("#tran");
			$("#tfg1_term1").focus();
			return false;
		}
	}

	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		if ($("input[name='tfg1_mod_claim1']").eq(0).prop("checked") == true) {
			if ($("#tfg1_term2").val() == "") {
				alert(errName1 + "���o���ť�,�Э��s��J!!");
				settab("#tran");
				$("#tfg1_term2").focus();
				return false;
			}
		}
	}

	//�I��L�I���������ˬd
	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		if ($("input[name='tfg1_mod_claim1']").eq(1).prop("checked") == true) {
			if ($("#fl_term1").val() == "") {
				alert(errName + "���o���ť�,�Э��s��J!!");
				settab("#tran");
				$("#fl_term1").focus();
				return false;
			}
			$("#tfg1_term1").val($("#fl_term1").val());
		}
	}

	if ($("input[name=tfzd_Mark]").prop("checked").length == 0) {
		alert("�п�J�ӽФH!!");
		settab("#tran");
		$("input[name='tfzd_Mark']").eq(0).focus();
		return false;
	}

	//***���v�ӫ~
	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		if ($("input[name=tfl1_mod_type]").prop("checked").length == 0) {
			alert("�п�ܱ��v�ӫ~���������v�γ������v!!");
			settab("#tran");
			$("input[name='tfl1_mod_type']").eq(0).focus();
			return false;
		}
		if ($("#mod_count").val() != "" || $("#mod_dclass").val() != "") {
			$("#tfg1_mod_class").val("Y");
		} else {
			$("#tfg1_mod_class").val("N");
		}
	}

	//�����ˬd
	if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
		if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
			settab("#tran");
			$("#O_item1").focus();
			return false;
		}
	}
	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;

	//���v�h���ˬd
	if ($("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6") {
		var title_name = "";
		if ($("#tfy_Arcase").val().Left(3) == "FL5") { title_name = "���v"; } else { title_name = "�Q���v"; }
		if (CInt($("#tot_num21").val()) <= 1) {
			alert(title_name + "�ץ�п�J�h��!!!");
			settab("#tran");
			$("#tot_num21").focus();
			return false;
		}
		var tot_num = CInt($("#tot_num21").val());//�@N��
		var ctrlcnt = 0;//����J�Ȫ����
		for (var i = 1; i <= CInt($("#tot_num21").val()); i++) {
			if ($("#appl_nameb_" + i).val() != "" && $("#dseqb_" + i).val() != "") {
				ctrlcnt++;
			}
		}
		if (tot_num != ctrlcnt) {
			var answer = title_name + "���(�@ " + tot_num + " ��)�P�]�t�D�n�שʿ�J���(�@ " + ctrlcnt + " ��)���šA\n�O�_�T�w���w��Ʀ@ " + ctrlcnt + " ��H";
			if (answer) {
				$("#tot_num21").val(ctrlcnt).triggerHandler("change");
			} else {
				settab("#tran");
				$("#tot_num21").focus();
				return false;
			}
		}
		$("#nfy_tot_num").val($("#tot_num21").val());

		for (var x = 1; x <= CInt($("#nfy_tot_num").val()); x++) {
			if ($("input[name='case_stat1b_" + x + "']:eq(1)").prop("checked") == true) {
				if ($("#keydseqb_" + x).val() == "N") {
					alert("���ҽs��" + x + "�ܰʹL�A�Ы�[�T�w]���s�A���s������!!!");
					settab("#tran");
					$("#keydseqb_" + x).focus();
					return false;
				}
			}
		}
	} else {
		$("#nfy_tot_num").val("1");
	}

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfg1_seq").val($("#tfzb_seq").val());
	$("#tfg1_seq1").val($("#tfzb_seq1").val());

	return true;
}