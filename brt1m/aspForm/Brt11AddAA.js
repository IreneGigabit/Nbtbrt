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

	//�����ˬd
	if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
		if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
			settab("#tran");
			$("#O_item1").focus();
			return false;
		}
	}
	
	//�ˬd�j���׽дڵ��O�ˬd&����
	if (main.chkAr() == false) return false;

	//*****�ץ󤺮e
	if ($("input[name=tfgd_mod_claim1]").eq(0).prop("checked") == true) {
		if (IsEmpty($("#tfn1_term1").val())) {
			alert("�M�ΰ_�餣�o���ťաA�Э��s��J!!!");
			settab("#tran");
			$("#tfn1_term1").focus();
			return false;
		} else {
			$("#tfg3_term1").val($("#tfn1_term1").val());
		}
		if (IsEmpty($("#tfn1_term2").val())) {
			alert("�M�Ψ��餣�o���ťաA�Э��s��J!!!");
			settab("#tran");
			$("#tfn1_term2").focus();
			return false;
		} else {
			$("#tfg3_term2").val($("#tfn1_term2").val());
		}
	} else if ($("input[name=tfgd_mod_claim1]").eq(1).prop("checked") == true) {
		if (IsEmpty($("#tfn2_term1").val())) {
			alert("�ӽФ餣�o���ťաA�Э��s��J!!!");
			settab("#tran");
			$("#tfn2_term1").focus();
			return false;
		} else {
			$("#tfg3_term1").val($("#tfn2_term1").val());
		}
	}

	if ($("input[name=tfgd_tran_Mark]").prop("checked").length == 0) {
		alert("�п�J�ҩ��Ѻ���!!");
		settab("#tran");
		$("input[name=tfgd_tran_Mark]").eq(0).focus();
		return false;
	}
	
	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum", "apclass", "tfgd_agt_no1") == false) return false;

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfgd_seq").val($("#tfzb_seq").val());
	$("#tfgd_seq1").val($("#tfzb_seq1").val());

	//reg.action="Brt11AddAA.asp"	
	//$("#submittask").val("Add");
	//If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	//reg.Submit
}