main.savechkA5 = function () {
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

	switch ($("#tfy_Arcase").val().Left(3)) {
		case "FD1":
			//�X�W�N�z�H�ˬd
			if (main.chkAgt("apnum", "apclass", "ttg1_agt_no") == false) return false;

			if (IsEmpty($("#tfg1_div_arcase").val())) {
				alert("�п�ܤ��Ϋ�ש�");
				settab("#tran");
				$("#tfg1_div_arcase").focus();
				return false;
			} else {
				$("#tfy_div_arcase").val($("#tfg1_div_arcase").val());
			}

			if (IsEmpty($("#tot_num1").val())) {
				alert("�п�J���Υ��");
				settab("#tran");
				$("#tot_num1").focus();
				return false;
			} else {
				$("#nfy_tot_num").val($("#tot_num1").val());
			}

			if ($("#ttz1_Z2").prop("checked") == true) {
				if ($("#ttz1_Z2C").val() == "") {
					alert("����G���Ŀ�A�п�J�����Υ�Ƥ����ΥӽЮѰƥ�����");
					settab("#tran");
					$("#ttz1_Z2C").focus();
				}
			}
			if ($("#ttz1_Z3").prop("checked") == true) {
				if ($("#ttz1_Z3C").val() == "") {
					alert("����T���Ŀ�A�п�J���Ϋᤧ�Ӽе��U�ӽЮѥ����Ψ����������");
					settab("#tran");
					$("#ttz1_Z3C").focus();
				}
			}
			//***���w���O�ƥ��ˬd
			var inputCount = $("[id^='FD2_class_count_'][value!='']").length;//����J���O�����
			if (inputCount == 0) {
				alert("�����Υ�ơA���L��J���ΰӫ~/�A�����O�B�W�١B�ҩ����e�μЪ��A�п�J�I�I�I");
				settab("#tran");
				$("#FD2_class_count_1").focus();
				return false;
			}

			if (CInt($("#tot_num1").val()) != 0) {
				var pname = CInt($("#tot_num1").val());//���ά�N��
				var kname = $("[id^='FD1_class_count_'][value!='']").length;//����J���O�����
				if (pname != kname) {
					var answer = "���Υ��(�@ " + pname + " ��)�P��J���Ϋ����O����(�@ " + kname + " ��)���šA\n�O�_�T�w���Ϋ����O���ئ@ " + kname + " ���H";
					if (answer) {
						$("#tot_num1").val(kname).triggerHandler("change");
					} else {
						settab("#tran");
						$("#tot_num1").focus();
						return false;
					}
				}
			}

			for (var a = 1; a <= CInt($("#tot_num1").val()); a++) {
				var class_cnt = $("#FD1_class_count_" + a).length;//�Ӥ��ο�J���@N��
				var input_cnt = $("[id^='classa_" + a + "_'][value!='']").length;//�Ӥ��ι�ڦ���J�����O�ƶq

				if (class_cnt != input_cnt) {
					var answer = "���Ϋ���w�ϥΰӫ~���O����" + a + "(�@ " + class_cnt + " ��)�P��J���w�ϥΰӫ~(�@ " + input_cnt + " ��)���šA\n�O�_�T�w���w�ϥΰӫ~�@ " + input_cnt + " ���H";
					if (answer) {
						$("#FD1_class_count_" + a).val(input_cnt).triggerHandler("change");
					} else {
						settab("#tran");
						$("#FD1_class_count_" + a).focus();
						return false;
					}
				}
			}

			for (var a = 1; a <= CInt($("#tot_num1").val()); a++) {
				if ($("input[name='FD1_Marka_" + a + "']:checked").length == 0) {
					alert("�п�ܤ���" + NumberToCh(a) + "�W�ٺ����G");
					settab("#tran");
					$("input[name=FD1_Marka_" + a + "']").eq(0).focus();
					return false;
				}

				//�ˬd���w���O���L����
				var objClass = {};
				for (var r = 1; r <= CInt($("#FD1_class_count_" + a).val()); r++) {
					var lineTa = $("#classa_" + a + "_" + r).val();
					if (lineTa != "" && objClass[lineTa]) {
						alert("�ӫ~���O����,�Э��s��J!!!");
						$("#classa_" + a + "_" + r).focus();
						return false;
					} else {
						objClass[lineTa] = { flag: true, idx: r };
					}
				}
			}

			//�����ˬd
			if ($("#O_item11").val() == "" && $("input[name=O_item12]").prop("checked").length > 0) {
				if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
					settab("#tran");
					$("#O_item11").focus();
					return false;
				}
			}
			break;
		
		case "FD2": case "FD3":
			//�X�W�N�z�H�ˬd
			if (main.chkAgt("apnum", "apclass", "ttg2_agt_no") == false) return false;

			if (IsEmpty($("#tot_num2").val())) {
				alert("�п�J���Υ��");
				settab("#tran");
				$("#tot_num2").focus();
				return false;
			} else {
				$("#nfy_tot_num").val($("#tot_num2").val());
			}

			if ($("#ttz2_Z2").prop("checked") == true) {
				if ($("#ttz2_Z2C").val() == "") {
					alert("����G���Ŀ�A�п�J�����Υ�Ƥ����ΥӽЮѰƥ�����");
					settab("#tran");
					$("#ttz2_Z2C").focus();
				}
			}
			//***���w���O�ƥ��ˬd
			var inputCount = $("[id^='FD2_class_count_'][value!='']").length;//����J���O�����
			if (inputCount == 0) {
				alert("�����Υ�ơA���L��J���ΰӫ~/�A�����O�B�W�١B�ҩ����e�μЪ��A�п�J�I�I�I");
				settab("#tran");
				$("#FD2_class_count_1").focus();
				return false;
			}

			if (CInt($("#tot_num2").val()) != 0) {
				var pname = CInt($("#tot_num2").val());//���ά�N��
				var kname = $("[id^='FD2_class_count_'][value!='']").length;//����J���O�����
				if (pname != kname) {//����J���O�����
					var answer = "���Υ��(�@ " + pname + " ��)�P��J���Ϋ����O����(�@ " + kname + " ��)���šA\n�O�_�T�w���Ϋ����O���ئ@ " + kname + " ���H";
					if (answer) {
						$("#tot_num2").val(kname).triggerHandler("change");
					} else {
						settab("#tran");
						$("#tot_num2").focus();
						return false;
					}
				}
			}

			for (var a = 1; a <= CInt($("#tot_num2").val()); a++) {
				var class_cnt = $("#FD2_class_count_" + a).length;//�Ӥ��ο�J���@N��
				var input_cnt = $("[id^='classb_" + a + "_'][value!='']").length;//�Ӥ��ι�ڦ���J�����O�ƶq

				if (class_cnt != input_cnt) {
					var answer = "���Ϋ���w�ϥΰӫ~���O����" + a + "(�@ " + class_cnt + " ��)�P��J���w�ϥΰӫ~(�@ " + input_cnt + " ��)���šA\n�O�_�T�w���w�ϥΰӫ~�@ " + input_cnt + " ���H";
					if (answer) {
						$("#FD2_class_count_" + a).val(input_cnt).triggerHandler("change");
					} else {
						settab("#tran");
						$("#FD2_class_count_" + a).focus();
						return false;
					}
				}
			}

			for (var a = 1; a <= CInt($("#tot_num2").val()); a++) {
				if ($("input[name='FD2_Markb_" + a + "']:checked").length == 0) {
					alert("�п�ܤ���" + NumberToCh(a) + "�W�ٺ����G");
					settab("#tran");
					$("input[name='FD2_Markb_" + a + "']").eq(0).focus();
					return false;
				}

				//�ˬd���w���O���L����
				var objClass = {};
				for (var r = 1; r <= CInt($("#FD2_class_count_" + a).val()); r++) {
					var lineTa = $("#classb_" + a + "_" + r).val();
					if (lineTa != "" && objClass[lineTa]) {
						alert("�ӫ~���O����,�Э��s��J!!!");
						$("#classb_" + a + "_" + r).focus();
						return false;
					} else {
						objClass[lineTa] = { flag: true, idx: r };
					}
				}
			}

			//�����ˬd
			if ($("#O_item21").val() == "" && $("input[name=O_item22]").prop("checked").length > 0) {
				if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
					settab("#tran");
					$("#O_item21").focus();
					return false;
				}
			}
			break;
	}

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;

	//�ˬd�j���׽дڵ��O�ˬd&����
	if (main.chkAr() == false) return false;
	
	$("#F_tscode,#tfzd_Tcn_mark").unlock();

	return true;
}