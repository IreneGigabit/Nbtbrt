main.savechkA6 = function () {
	//�Ȥ��p���H�ˬd
	if (main.chkCustAtt() == false) return false;

	//�ӽФH�ˬd
	if (main.chkApp() == false) return false;
	
	if ($("#tfy_Arcase").val().Left(3) == "FC1" || $("#tfy_Arcase").val().Left(3) == "FC9" || $("#tfy_Arcase").val().Left(3) == "FC5"
		|| $("#tfy_Arcase").val().Left(3) == "FC7" || $("#tfy_Arcase").val().Left(3) == "FCA" || $("#tfy_Arcase").val().Left(3) == "FCB"
		|| $("#tfy_Arcase").val().Left(3) == "FCF" || $("#tfy_Arcase").val().Left(3) == "FCH") {
		for (var tapnum = 1; tapnum <= CInt($("#FC1_apnum").val()); tapnum++) {
			if ($("#dbmo1_old_no_" + tapnum).val() != "") {
				$("#tft1_old_no_" + tapnum).val($("#dbmo1_old_no_" + tapnum).val());
			}
			if ($("#dbmo1_ocname1_" + tapnum).val() != "") {
				$("#tft1_ocname1_" + tapnum).val($("#dbmo1_ocname1_" + tapnum).val());
			}
			if ($("#dbmo1_ocname2_" + tapnum).val() != "") {
				$("#tft1_ocname2_" + tapnum).val($("#dbmo1_ocname2_" + tapnum).val());
			}
			if ($("#dbmo1_oename1_" + tapnum).val() != "") {
				$("#tft1_oename1_" + tapnum).val($("#dbmo1_oename1_" + tapnum).val());
			} if ($("#dbmo1_oename2_" + tapnum).val() != "") {
				$("#tft1_oename2_" + tapnum).val($("#dbmo1_oename2_" + tapnum).val());
			}
		}
	}

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
	
	//****���w�ϥΰӫ~/�A�����O�ΦW��
	if ($("#tfy_Arcase").val().Left(3) != "FC3") {
		//�D�ɰӫ~���O�ˬd
		if (main.chkGood() == false) return false;
	} else {
		//���w���O�ˬd
		if ($("#tft3_class_count2").val() != "") {
			//2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
			if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
				var inputCount = 0;
				for (var j = 1; j <= CInt($("#num32").val()); j++) {
					if ($("#good_name32_" + j).val() != "" && $("#class32_" + j).val() == "") {
						//����J�ӫ~�W��,���S��J���O
						alert("�п�J���O!");
						settab("#tran");
						$("#class32_" + j).focus();
						return false;
					}
					if (br_form.checkclass(j) == false) {//�ˬd���O�d��0~45
						$("#class32_" + j).focus();
						settab("#tran");
						return false;
					}
					if ($("#class32_" + j).val() != "") {
						inputCount++;//��ڦ���J�~�n+
					}
				}
			}
			//�ˬd���w���O���L����
			var objClass = {};
			for (var r = 1; r <= CInt($("#num32").val()); r++) {
				var lineTa = $("#class32_" + r).val();
				if (lineTa != "" && objClass[lineTa]) {
					alert("�ӫ~���O����,�Э��s��J!!!");
					$("#class32_" + r).focus();
					return false;
				} else {
					objClass[lineTa] = { flag: true, idx: r };
				}
			}
			$("#ctrlcount32").val(inputCount == 0 ? "" : inputCount);
			if (CInt($("#tft3_class_count2").val()) != CInt($("#num32").val())) {
				var answer = "���w�ϥΰӫ~���O����(�@ " + CInt($("#tft3_class_count2").val()) + " ��)�P��J���w�ϥΰӫ~(�@ " + CInt($("#num32").val()) + " ��)���šA\n�O�_�T�w���w�ϥΰӫ~�@ " + CInt($("#num32").val()) + " ���H";
				if (answer) {
					$("#tft3_class_count2").val($("#num32").val());
				} else {
					settab("#tran");
					$("#tft3_class_count2").focus();
					return false;
				}
			}
		}
	}

	//***���w���O�ƥ��ˬd
	var prt_code = $("#tfy_Arcase option:selected").attr("v1");
	var f = prt_code.substr(2, 1);
	switch ($("#tfy_Arcase").val()) {
		case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
			if (IsEmpty($("#tft1_mod_count" + f + "1").val()) == false) {
				var kname = CInt($("#tft1_mod_count" + f + "1").val());//���
				var gname = $("[id^='new_no" + f + "'][value!='']").length;//����J�ӽЮ׸������
				
				if (kname != gname) {
					var answer = "���w���(�@ " + kname + " ��)�P��J���(�@ " + gname + " ��)���šA\n�O�_�T�w���w��Ʀ@ " + gname + " ���H";
					if (answer) {
						$("#tft1_mod_count" + f + "1").val(gname).triggerHandler("change");
					} else {
						settab("#tran");
						$("#tft1_mod_count" + f + "1").focus();
						return false;
					}
				}
			}
			var old_no_flag = "N";
			for (var apnum = 1; apnum <= CInt($("#FC1_apnum").val()); apnum++) {
				if ($("#dbmo1_old_no_" + apnum).val() != "") {
					old_no_flag = "Y";
					break;
				}
			}
			if (old_no_flag == "Y") {
				if ($("input[name='tfzr_mod_ap']").prop("checked") == false) {
					alert("���ӽ��v�Q�����P�A�ФĿ��ܧ�ƶ��I�I");
					settab("#tran");
					$("input[name='tfzr_mod_ap']").focus();
					return false;
				}
			}
			break;
		case "FC11": case "FC5": case "FC7": case "FCH":
			var old_no_flag = "N";
			for (var apnum = 1; apnum <= CInt($("#FC1_apnum").val()); apnum++) {
				if ($("#dbmo1_old_no_" + apnum).val() != "") {
					old_no_flag = "Y";
					break;
				}
			}
			if (old_no_flag == "Y") {
				if ($("input[name='tfzr1_mod_ap']").prop("checked") == false) {
					alert("���ӽ��v�Q�����P�A�ФĿ��ܧ�ƶ��I�I");
					settab("#tran");
					$("input[name='tfzr1_mod_ap']").focus();
					return false;
				}
			}
			break;
		case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
			break;
		case "FC3":
			for (var j = 1; j <= 2; j++) {
				var kname = CInt($("#tft3_class_count" + j).val());//���
				var gname = $("[id^='class3" + j + "_'][value!='']").length;//����J���O�����
				
				if (kname != gname) {
					var errname = "";
					if (j == 1) errname = "�����Y"; else if (j == 2) errname = "���Y����w";
					var answer = "�ӫ~(�A��)�W�٫��w���(�@ " + kname + " ��)�P��J���(�@ " + gname + " ��)���šA\n�O�_�T�w���w��Ʀ@ " + gname + " ���H";
					if (answer) {
						$("#tft3_class_count" + j).val(gname).triggerHandler("change");
					} else {
						settab("#tran");
						$("#tft3_class_count" + j).focus();
						return false;
					}
				}
			}
			break;
		case "FC4":
			break;
	}

	//***�ܧ󶵥�*********************
	switch ($("#tfy_Arcase").val()) {
		case "FC1": case "FC10": case "FC9": case "FCA": case "FCB":
			//FC1form
			var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_oth", "mod_oth1", "mod_oth2", "mod_claim1"];
			for (var m in arr_mod) {
				if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
					$("#tfg1_" + arr_mod[m]).val("Y");
				} else {
					$("#tfg1_" + arr_mod[m]).val("N");
				}
			}
			break;
		case "FC11": case "FC5": case "FC7": case "FCH":
			//FC11form
			var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_oth", "mod_oth1", "mod_oth2", "mod_claim1"];
			for (var m in arr_mod) {
				if ($("#tfzr1_" + arr_mod[m]).prop("checked") == true) {
					$("#tfg1_" + arr_mod[m]).val("Y");
				} else {
					$("#tfg1_" + arr_mod[m]).val("N");
				}
			}
			break;
		case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
			//FC2form
			var arr_mod = ["mod_agt", "mod_oth", "mod_oth1", "mod_dmt", "mod_claim1", "mod_claim2"];
			for (var m in arr_mod) {
				if ($("#tfop_" + arr_mod[m]).prop("checked") == true) {
					$("#tfg2_" + arr_mod[m]).val("Y");
				} else {
					$("#tfg2_" + arr_mod[m]).val("N");
				}
			}

			if ($("#tfy_Arcase").val() == "FCC") {
				if ($("#tfg2_mod_agt").val() == "Y") {
					if ($("input[name=tfg2_mod_agttype]:checked").val() != "A") {
						alert("�����U�ƶ��ܧ�(�s�W�N�z�H)�A�N�z�H���ʽ��I��u�s�W�v�I");
						return false;
					}
				} else {
					alert("�����U�ƶ��ܧ�(�s�W�N�z�H)�A�Щ�N�z�H��ƫe�Ŀ�I");
					return false;
				}
			}

			if ($("#tfy_Arcase").val() == "FCD") {
				if ($("#tfg2_mod_agt").val() == "Y") {
					if ($("input[name=tfg2_mod_agttype]:checked").val() != "D") {
						alert("�����U�ƶ��ܧ�(�M�P�N�z�H)�A�N�z�H���ʽ��I��u�M�P�v�I");
						return false;
					}
				} else {
					alert("�����U�ƶ��ܧ�(�M�P�N�z�H)�A�Щ�N�z�H��ƫe�Ŀ�I");
					return false;
				}
			}
			break;
		case "FC21": case "FC8": case "FC6": case "FCI":
			//FC21form
			var arr_mod = ["mod_agt", "mod_oth", "mod_oth1", "mod_dmt", "mod_claim1", "mod_claim2"];
			for (var m in arr_mod) {
				if ($("#tfop1_" + arr_mod[m]).prop("checked") == true) {
					$("#tfg2_" + arr_mod[m]).val("Y");
				} else {
					$("#tfg2_" + arr_mod[m]).val("N");
				}
			}
			if ($("#tfop1_mod_agttypeC").prop("checked") == true) $("#tfg2_mod_agttypeC").prop("checked", true);
			if ($("#tfop1_mod_agttypeA").prop("checked") == true) $("#tfg2_mod_agttypeA").prop("checked", true);
			if ($("#tfop1_mod_agttypeD").prop("checked") == true) $("#tfg2_mod_agttypeD").prop("checked", true);
			break;
		case "FC3":
			//FC3form
			if (IsEmpty($("#tft3_class1").val())) {
				$("#tfg3_mod_class").val("N");
			} else {
				$("#tfg3_mod_class").val("Y");
			}
			break;
		case "FC4":
			break;
	}

	//*****�ץ󤺮e
	switch ($("#tfy_Arcase").val()) {
		case "FC1": case "FC10": case "FC9": case "FCA": case "FCB":
			//�X�W�N�z�H�ˬd(apcust_fc_re1)
			if (main.chkAgt("FC2_apnum", "ttg1_apclass", "ttg1_agt_no") == false) return false;
			if ($("#tfy_Arcase").val() == "FCA") {
				if ($("#FC1_add_agt_no").val() == "") {
					alert("���ӽШƶ��ܧ�(�s�W�N�z�H)�A�п�ܷs�W�N�z�H�I");
					settab("#tran");
					$("#FC1_add_agt_no").focus();
					return false;
				}
			}
			break;
		case "FC11": case "FC5": case "FC7": case "FCH":
			//�X�W�N�z�H�ˬd(apcust_fc_re)
			if (main.chkAgt("FC2_apnum", "ttg1_apclass", "ttg11_agt_no") == false) return false;
			break;
		case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
			//�X�W�N�z�H�ˬd(apcust_fc_re1)
			if (main.chkAgt("FC0_apnum", "ttg2_apclass", "ttg2_agt_no") == false) return false;
			break;
		case "FC21": case "FC6": case "FC8": case "FCI":
			//�X�W�N�z�H�ˬd(apcust_fc_re1)
			if (main.chkAgt("FC0_apnum", "ttg2_apclass", "ttg21_agt_no") == false) return false;
			break;
		case "FC3":
			//�X�W�N�z�H�ˬd(apcust)
			if (main.chkAgt("apnum", "apclass", "ttg3_agt_no") == false) return false;
			break;
		case "FC4":
			//�X�W�N�z�H�ˬd(apcust)
			if (main.chkAgt("apnum", "apclass", "ttg4_agt_no") == false) return false;
				
			if ($("input[name=fr4_S_Mark]").eq(0).prop("checked") == true) {
				$("#tfzd_Pul").val("2");
				$("#tfzd_S_Mark").val("");
			} else if ($("input[name=fr4_S_Mark]").eq(0).prop("checked") == true) {
				$("#tfzd_Pul").val("2");
				$("#tfzd_S_Mark").val("S");
			}
			break;
	}

	//���״_���ˬd
	if (main.chkEndBack() == false) return false;
	
	$("#F_tscode,#tfzd_Tcn_mark,#tfy_case_stat").unlock();
	$("#tfgp_seq").val($("#tfzb_seq").val());
	$("#tfgp_seq1").val($("#tfzb_seq1").val());

	//�ˬd�j���׽дڵ��O�ˬd&����
	if (main.chkAr() == false) return false;
		
	//�ܧ�@�צh�󱱨�
	switch ($("#tfy_Arcase").val()) {
		case "FC11": case "FC5": case "FC7": case "FCH":
			if (CInt($("#tot_num11").val()) <= 1) {
				alert("�ܧ�ץ�п�J�h��!!!");
				settab("#tran");
				$("#tot_num11").focus();
				return false;
			}
			var tot_num = CInt($("#tot_num11").val());//�@N��
			var ctrlcnt = 0;//����J�Ȫ����
			for (var i = 1; i <= CInt($("#tot_num11").val()); i++) {
				if ($("#appl_namea_" + i).val() != "" && $("#dseqa_" + i).val() != "") {
					ctrlcnt++;
				}
			}
			if (tot_num != ctrlcnt) {
				var answer = "�ܧ���(�@ " + tot_num + " ��)�P�]�t�D�n�שʿ�J���(�@ " + ctrlcnt + " ��)���šA\n�O�_�T�w���w��Ʀ@ " + ctrlcnt + " ��H";
				if (answer) {
					$("#tot_num11").val(ctrlcnt).triggerHandler("change");
				} else {
					settab("#tran");
					$("#tot_num11").focus();
					return false;
				}
			}
			$("#nfy_tot_num").val($("#tot_num11").val());
			break;
		case "FC21": case "FC6": case "FC8": case "FCI":
			if (CInt($("#tot_num21").val()) <= 1) {
				alert("�ܧ�ץ�п�J�h��!!!");
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
				var answer = "�ܧ���(�@ " + tot_num + " ��)�P�]�t�D�n�שʿ�J���(�@ " + ctrlcnt + " ��)���šA\n�O�_�T�w���w��Ʀ@ " + ctrlcnt + " ��H";
				if (answer) {
					$("#tot_num21").val(ctrlcnt).triggerHandler("change");
				} else {
					settab("#tran");
					$("#tot_num21").focus();
					return false;
				}
			}
			$("#nfy_tot_num").val($("#tot_num21").val());
			break;
		default:
			$("#nfy_tot_num").val("1");
			break;
	}

	switch ($("#tfy_Arcase").val()) {
		case "FC11": case "FC5": case "FC7": case "FCH":
			for (var x = 1; x <= CInt($("#nfy_tot_num").val()); x++) {
				if ($("input[name='case_stat1a_" + x + "']:eq(1)").prop("checked") == true) {
					if ($("#keydseqa_" + x).val() == "N") {
						alert("���ҽs��" + x + "�ܰʹL�A�Ы�[�T�w]���s�A���s������!!!");
						settab("#tran");
						$("#btndseq_oka_" + x).focus();
						return false;
					}
				}
			} break;
		case "FC21": case "FC6": case "FC8": case "FCI":
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
			break;
	}
	//�����ˬd
	switch ($("#tfy_Arcase").val()) {
		case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
			if ($("#O_item21").val() == "" && $("input[name=O_item22]").prop("checked").length > 0) {
				if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
					settab("#tran");
					$("#O_item21").focus();
					return false;
				}
			}
			break;
		case "FC21": case "FC6": case "FC8":
			if ($("#O_item211").val() == "" && $("input[name=O_item221]").prop("checked").length > 0) {
				if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
					settab("#tran");
					$("#O_item211").focus();
					return false;
				}
			}
			break;
		case "FC3":
			if ($("#O_item31").val() == "" && $("input[name=O_item32]").prop("checked").length > 0) {
				if (confirm("������Ƥ��������J�A�T�w�s��?") == false) {
					settab("#tran");
					$("#O_item31").focus();
					return false;
				}
			}
			break;
	}

	return true;
}