main.savechkA8 = function () {
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
	
	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;

	//����h���ˬd
	var title_name = "";
	if ($("#tfy_Arcase").val().Left(3) == "FT2") {
		title_name = "����";
	
		if (CInt($("#tot_num21").val()) <= 1) {
			alert(title_name + "�ץ�п�J�h��!!!");
			settab("#tran");
			$("#tot_num21").focus();
			return false;
		}

		if ($("#tot_num21").val() != "") {
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
		}

		$("#nfy_tot_num").val($("#tot_num21").val());

		for (var x = 1; x <= CInt($("#nfy_tot_num").val()); x++) {
			if ($("input[name='case_stat1b_" + x + "']:eq(1)").prop("checked") == true) {
				if ($("#keydseqb_" + x).val() == "N") {
					alert("���ҽs��" + x + "�ܰʹL�A�Ы�[�T�w]���s�A���s������!!!");
					settab("#tran");
					$("#btndseq_okb_" + x).focus();
					return false;
				}
			}
		}
	} else {
		$("#nfy_tot_num").val("1");
	}

	//�ˬd�j���׽дڵ��O�ˬd&����
	if (main.chkAr() == false) return false;

	//*****�ץ󤺮e
	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfg1_seq").val($("#tfzb_seq").val());
	$("#tfg1_seq1").val($("#tfzb_seq1").val());

	return true;
}