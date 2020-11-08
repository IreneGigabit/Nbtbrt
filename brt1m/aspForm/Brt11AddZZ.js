main.savechk = function () {
	//客戶聯絡人檢查
	if (main.chkCustAtt() == false) return false;
	
	//申請人檢查
	if (main.chkApp() == false) return false;
	
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
	
	//主檔商品類別檢查
	if (main.chkGood() == false) return false;

	//檢查大陸案請款註記檢查&給值
	if (main.chkAr() == false) return false;

	//*****案件內容
	if ($("#tfy_Arcase").val().Left(3) == "FOB") {
		if ($("#tfg1_other_item").val() == "") {
			alert("影印內容沒有勾選，請輸入!!");
			settab("#tran");
			$("#ttz1_P1").focus();
			return false;
		}
		$("#tfzd_mark").val($("input[name='fr_Mark']:checked").val() || "");
	}
	if ($("#tfy_Arcase").val().Left(3) == "AD7") {
		if ($("input[name=fr4_remark3]").prop("checked").length == 0) {
			alert("請輸入申請舉行聽證之案件種類!!");
			settab("#tran");
			$("input[name='fr4_remark3']").eq(0).focus();
			return false;
		} else {
			$("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
		}

		if ($("input[name=fr4_Mark]").prop("checked").length == 0) {
			alert("請輸入申請人種類!!");
			settab("#tran");
			$("input[name='fr4_Mark']").eq(0).focus();
			return false;
		} else {
			$("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
		}

		if ($("input[name=fr4_tran_mark]").prop("checked").length == 0) {
			alert("請輸入對照當事人種類!!");
			settab("#tran");
			$("input[name='fr4_tran_mark']").eq(0).focus();
			return false;
		}

		if (CInt($("#DE1_apnum").val()) == 0) {
			alert("請輸入對照當事人資料！");
			settab("#tran");
			return false;
		}
		for (var k = 1; k <= CInt($("#DE1_apnum").val()); k++) {
			if ($("#tfr4_ncname1_" + k).val() == "") {
				alert("請輸入對照當事人名稱!!");
				settab("#tran");
				return false;
			}
		}
		if ($("#fr4_tran_remark1").val() == "") {
			alert("請輸入應舉行聽證之理由!!");
			settab("#tran");
			$("#fr4_tran_remark1").focus();
			return false;
		}
	} else if ($("#tfy_Arcase").val().Left(3) == "AD8") {
		if ($("input[name=fr4_remark3]").prop("checked").length == 0) {
			alert("請輸入申請舉行聽證之案件種類!!");
			settab("#tran");
			$("input[name='fr4_remark3']").eq(0).focus();
			return false;
		} else {
			$("#tfzd_remark3").val($("input[name='fr4_remark3']:checked").val() || "");
		}

		if ($("input[name=fr4_Mark]").prop("checked").length == 0) {
			alert("請輸入申請人種類!!");
			settab("#tran");
			$("input[name='fr4_Mark']").eq(0).focus();
			return false;
		} else {
			$("#tfzd_mark").val($("input[name='fr4_Mark']:checked").val() || "");
		}

		if ($("#fr4_tran_remark1").val() == "") {
			alert("請輸入新事證及陳述意見書!!");
			settab("#tran");
			$("#fr4_tran_remark1").focus();
			return false;
		}
	}
	//申請退費檢查
	if ($("#tfy_Arcase").val().Left(3) == "FOF") {
		if ($("#tfzf_other_item").val() == "") {
			alert("請輸入國庫支票抬頭名稱！！");
			settab("#tran");
			$("#tfzf_other_item").focus();
			return false;
		}
		if ($("#tfzf_debit_money").val() == "") {
			alert("請輸入退費金額！！");
			settab("#tran");
			$("#tfzf_debit_money").focus();
			return false;
		} else {
			if (IsNumeric($("#tfzf_debit_money").val()) == false) {
				alert("退費金額必須為數值，請重新輸入！！");
				settab("#tran");
				$("#tfzf_debit_money").focus();
				return false;
			}
		}
		if ($("#tfzf_other_item1").val() == "") {
			alert("請輸入規費收據號碼！！");
			settab("#tran");
			$("#tfzf_other_item1").focus();
			return false;
		}
		if ($("#tfzf_other_item2").val() == "") {
			//20190613增加 權限C可不輸入退費函字號
			if ((main.right & 256) != 0) {
				alert("請輸入本局通知退費函字號！！");
				settab("#tran");
				$("input[name='ttzf_F1']:eq(0)").focus();
				return false;
			}
		} else {
			if ($("input[name='ttzf_F1']:eq(0)").prop("checked") == true) {
				if ($("#F1_yy").val() == "" || $("#F1_word").val() == "" || $("#F1_no").val() == "") {
					alert("請輸入本局通知退費函字號！！");
					settab("#tran");
					$("#F1_yy").focus();
					return false;
				}
			}
			if ($("input[name='ttzf_F1']:eq(1)").prop("checked") == true) {
				if ($("#F2_yy").val() == "" || $("#F2_word").val() == "" || $("#F2_no").val() == "") {
					alert("請輸入本局通知退費函字號！！");
					settab("#tran");
					$("#F2_yy").focus();
					return false;
				}
			}
		}
		$("#tfzd_mark").val($("input[name='frf_mark']:checked").val() || "");
	}
	//申請補送文件檢查
	if ($("#tfy_Arcase").val().Left(3) == "FB7") {
		if ($("#tfb7_other_item").val() == "") {
			alert("請勾選補送文件！");
			return false;
		}
	}

	//申請撤回申請檢查
	if ($("#tfy_Arcase").val().Left(3) == "FW1") {
		if ($("#tfw1_mod_claim1").prop("checked") == false) {
			alert("請勾選「本申請案自請撤回」");
			return false;
		}
	}

	//結案復案檢查
	if (main.chkEndBack() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfg1_seq").val($("#tfzb_seq").val());
	$("#tfg1_seq1").val($("#tfzb_seq1").val());

	if ($("#tfy_Arcase").val().Left(3) == "FOB") {
		//出名代理人檢查
		if (main.chkAgt("apnum", "apclass", "tfg2_agt_no1") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "AD7" || $("#tfy_Arcase").val().Left(3) == "AD8") {
		//出名代理人檢查
		if (main.chkAgt("apnum", "apclass", "tfp4_agt_no") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "FOF") {
		//出名代理人檢查
		if (main.chkAgt("apnum", "apclass", "tfzf_agt_no1") == false) return false;
	} else if ($("#tfy_Arcase").val().Left(3) == "FB7") {
		//出名代理人檢查
		if (main.chkAgt("apnum", "apclass", "tfb7_agt_no1") == false) return false;
	} else {
		//出名代理人檢查
		if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;
	}
 
	//reg.action="Brt11AddZZ.asp"	
	//$("#submittask").val("Add");
	//If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	//reg.Submit
}