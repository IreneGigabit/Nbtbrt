main.savechkA6 = function () {
	//客戶聯絡人檢查
	if (main.chkCustAtt() == false) return false;

	//申請人檢查
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

	//日期格式檢查,抓class=dateField,有輸入則檢查
	if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢查"); return false; }
	if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢查"); return false; }
	if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢查"); return false; }
	
	//商標名稱檢查
	if (main.chkApplName() == false) return false;

	//必填欄位檢查
	if (main.chkRequire() == false) return false;

	//接洽內容相關檢查
	if (main.chkCaseForm() == false) return false;

	//新/舊案號
	if (main.chkNewOld() == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val() || "");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val() || "");
	$("#tfzd_Pul").val($("#tfzy_Pul").val());
	$("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
	$("#tfzd_prior_country").val($("#tfzy_prior_country").val());
	
	//****指定使用商品/服務類別及名稱
	if ($("#tfy_Arcase").val().Left(3) != "FC3") {
		//主檔商品類別檢查
		if (main.chkGood() == false) return false;
	} else {
		//指定類別檢查
		if ($("#tft3_class_count2").val() != "") {
			//2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
			if ($("#tfzd_S_Mark").val() != "M" && $("#tfzd_S_Mark").val() != "L") {
				var inputCount = 0;
				for (var j = 1; j <= CInt($("#num32").val()); j++) {
					if ($("#good_name32_" + j).val() != "" && $("#class32_" + j).val() == "") {
						//有輸入商品名稱,但沒輸入類別
						alert("請輸入類別!");
						settab("#tran");
						$("#class32_" + j).focus();
						return false;
					}
					if (br_form.checkclass(j) == false) {//檢查類別範圍0~45
						$("#class32_" + j).focus();
						settab("#tran");
						return false;
					}
					if ($("#class32_" + j).val() != "") {
						inputCount++;//實際有輸入才要+
					}
				}
			}
			//檢查指定類別有無重覆
			var objClass = {};
			for (var r = 1; r <= CInt($("#num32").val()); r++) {
				var lineTa = $("#class32_" + r).val();
				if (lineTa != "" && objClass[lineTa]) {
					alert("商品類別重覆,請重新輸入!!!");
					$("#class32_" + r).focus();
					return false;
				} else {
					objClass[lineTa] = { flag: true, idx: r };
				}
			}
			$("#ctrlcount32").val(inputCount == 0 ? "" : inputCount);
			if (CInt($("#tft3_class_count2").val()) != CInt($("#num32").val())) {
				var answer = "指定使用商品類別項目(共 " + CInt($("#tft3_class_count2").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num32").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num32").val()) + " 類？";
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

	//***指定類別數目檢查
	var prt_code = $("#tfy_Arcase option:selected").attr("v1");
	var f = prt_code.substr(2, 1);
	switch ($("#tfy_Arcase").val()) {
		case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
			if (IsEmpty($("#tft1_mod_count" + f + "1").val()) == false) {
				var kname = CInt($("#tft1_mod_count" + f + "1").val());//件數
				var gname = $("[id^='new_no" + f + "'][value!='']").length;//有輸入申請案號的件數
				
				if (kname != gname) {
					var answer = "指定件數(共 " + kname + " 類)與輸入件數(共 " + gname + " 類)不符，\n是否確定指定件數共 " + gname + " 類？";
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
					alert("有申請權利之讓與，請勾選變更事項！！");
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
					alert("有申請權利之讓與，請勾選變更事項！！");
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
				var kname = CInt($("#tft3_class_count" + j).val());//件數
				var gname = $("[id^='class3" + j + "_'][value!='']").length;//有輸入類別的件數
				
				if (kname != gname) {
					var errname = "";
					if (j == 1) errname = "擬減縮"; else if (j == 2) errname = "減縮後指定";
					var answer = "商品(服務)名稱指定件數(共 " + kname + " 類)與輸入件數(共 " + gname + " 類)不符，\n是否確定指定件數共 " + gname + " 類？";
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

	//***變更項目*********************
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
						alert("交辦註冊事項變更(新增代理人)，代理人異動請點選「新增」！");
						return false;
					}
				} else {
					alert("交辦註冊事項變更(新增代理人)，請於代理人資料前勾選！");
					return false;
				}
			}

			if ($("#tfy_Arcase").val() == "FCD") {
				if ($("#tfg2_mod_agt").val() == "Y") {
					if ($("input[name=tfg2_mod_agttype]:checked").val() != "D") {
						alert("交辦註冊事項變更(撤銷代理人)，代理人異動請點選「撤銷」！");
						return false;
					}
				} else {
					alert("交辦註冊事項變更(撤銷代理人)，請於代理人資料前勾選！");
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

	//*****案件內容
	switch ($("#tfy_Arcase").val()) {
		case "FC1": case "FC10": case "FC9": case "FCA": case "FCB":
			//出名代理人檢查(apcust_fc_re1)
			if (main.chkAgt("FC2_apnum", "ttg1_apclass", "ttg1_agt_no") == false) return false;
			if ($("#tfy_Arcase").val() == "FCA") {
				if ($("#FC1_add_agt_no").val() == "") {
					alert("交辦申請事項變更(新增代理人)，請選擇新增代理人！");
					settab("#tran");
					$("#FC1_add_agt_no").focus();
					return false;
				}
			}
			break;
		case "FC11": case "FC5": case "FC7": case "FCH":
			//出名代理人檢查(apcust_fc_re)
			if (main.chkAgt("FC2_apnum", "ttg1_apclass", "ttg11_agt_no") == false) return false;
			break;
		case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
			//出名代理人檢查(apcust_fc_re1)
			if (main.chkAgt("FC0_apnum", "ttg2_apclass", "ttg2_agt_no") == false) return false;
			break;
		case "FC21": case "FC6": case "FC8": case "FCI":
			//出名代理人檢查(apcust_fc_re1)
			if (main.chkAgt("FC0_apnum", "ttg2_apclass", "ttg21_agt_no") == false) return false;
			break;
		case "FC3":
			//出名代理人檢查(apcust)
			if (main.chkAgt("apnum", "apclass", "ttg3_agt_no") == false) return false;
			break;
		case "FC4":
			//出名代理人檢查(apcust)
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

	//結案復案檢查
	if (main.chkEndBack() == false) return false;
	
	$("#F_tscode,#tfzd_Tcn_mark,#tfy_case_stat").unlock();
	$("#tfgp_seq").val($("#tfzb_seq").val());
	$("#tfgp_seq1").val($("#tfzb_seq1").val());

	//檢查大陸案請款註記檢查&給值
	if (main.chkAr() == false) return false;
		
	//變更一案多件控制
	switch ($("#tfy_Arcase").val()) {
		case "FC11": case "FC5": case "FC7": case "FCH":
			if (CInt($("#tot_num11").val()) <= 1) {
				alert("變更案件請輸入多筆!!!");
				settab("#tran");
				$("#tot_num11").focus();
				return false;
			}
			var tot_num = CInt($("#tot_num11").val());//共N件
			var ctrlcnt = 0;//有輸入值的件數
			for (var i = 1; i <= CInt($("#tot_num11").val()); i++) {
				if ($("#appl_namea_" + i).val() != "" && $("#dseqa_" + i).val() != "") {
					ctrlcnt++;
				}
			}
			if (tot_num != ctrlcnt) {
				var answer = "變更件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
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
				alert("變更案件請輸入多筆!!!");
				settab("#tran");
				$("#tot_num21").focus();
				return false;
			}
			var tot_num = CInt($("#tot_num21").val());//共N件
			var ctrlcnt = 0;//有輸入值的件數
			for (var i = 1; i <= CInt($("#tot_num21").val()); i++) {
				if ($("#appl_nameb_" + i).val() != "" && $("#dseqb_" + i).val() != "") {
					ctrlcnt++;
				}
			}
			if (tot_num != ctrlcnt) {
				var answer = "變更件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
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
						alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
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
						alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
						settab("#tran");
						$("#btndseq_okb_" + x).focus();
						return false;
					}
				}
			}
			break;
	}
	//附註檢查
	switch ($("#tfy_Arcase").val()) {
		case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
			if ($("#O_item21").val() == "" && $("input[name=O_item22]").prop("checked").length > 0) {
				if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
					settab("#tran");
					$("#O_item21").focus();
					return false;
				}
			}
			break;
		case "FC21": case "FC6": case "FC8":
			if ($("#O_item211").val() == "" && $("input[name=O_item221]").prop("checked").length > 0) {
				if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
					settab("#tran");
					$("#O_item211").focus();
					return false;
				}
			}
			break;
		case "FC3":
			if ($("#O_item31").val() == "" && $("input[name=O_item32]").prop("checked").length > 0) {
				if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
					settab("#tran");
					$("#O_item31").focus();
					return false;
				}
			}
			break;
	}

	return true;
}