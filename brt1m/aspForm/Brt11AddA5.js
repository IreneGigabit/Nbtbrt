main.savechkA5 = function () {
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

	switch ($("#tfy_Arcase").val().Left(3)) {
		case "FD1":
			//出名代理人檢查
			if (main.chkAgt("apnum", "apclass", "ttg1_agt_no") == false) return false;

			if (IsEmpty($("#tfg1_div_arcase").val())) {
				alert("請選擇分割後案性");
				settab("#tran");
				$("#tfg1_div_arcase").focus();
				return false;
			} else {
				$("#tfy_div_arcase").val($("#tfg1_div_arcase").val());
			}

			if (IsEmpty($("#tot_num1").val())) {
				alert("請輸入分割件數");
				settab("#tran");
				$("#tot_num1").focus();
				return false;
			} else {
				$("#nfy_tot_num").val($("#tot_num1").val());
			}

			if ($("#ttz1_Z2").prop("checked") == true) {
				if ($("#ttz1_Z2C").val() == "") {
					alert("附件二有勾選，請輸入按分割件數之分割申請書副本份數");
					settab("#tran");
					$("#ttz1_Z2C").focus();
				}
			}
			if ($("#ttz1_Z3").prop("checked") == true) {
				if ($("#ttz1_Z3C").val() == "") {
					alert("附件三有勾選，請輸入分割後之商標註冊申請書正本及其相關文件份數");
					settab("#tran");
					$("#ttz1_Z3C").focus();
				}
			}
			//***指定類別數目檢查
			var inputCount = $("[id^='FD2_class_count_'][value!='']").length;//有輸入類別的件數
			if (inputCount == 0) {
				alert("有分割件數，但無輸入分割商品/服務類別、名稱、證明內容及標的，請輸入！！！");
				settab("#tran");
				$("#FD2_class_count_1").focus();
				return false;
			}

			if (CInt($("#tot_num1").val()) != 0) {
				var pname = CInt($("#tot_num1").val());//分割為N件
				var kname = $("[id^='FD1_class_count_'][value!='']").length;//有輸入類別的件數
				if (pname != kname) {
					var answer = "分割件數(共 " + pname + " 類)與輸入分割後類別項目(共 " + kname + " 類)不符，\n是否確定分割後類別項目共 " + kname + " 類？";
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
				var class_cnt = $("#FD1_class_count_" + a).length;//該分割輸入的共N類
				var input_cnt = $("[id^='classa_" + a + "_'][value!='']").length;//該分割實際有輸入的類別數量

				if (class_cnt != input_cnt) {
					var answer = "分割後指定使用商品類別項目" + a + "(共 " + class_cnt + " 類)與輸入指定使用商品(共 " + input_cnt + " 類)不符，\n是否確定指定使用商品共 " + input_cnt + " 類？";
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
					alert("請選擇分割" + NumberToCh(a) + "名稱種類：");
					settab("#tran");
					$("input[name=FD1_Marka_" + a + "']").eq(0).focus();
					return false;
				}

				//檢查指定類別有無重覆
				var objClass = {};
				for (var r = 1; r <= CInt($("#FD1_class_count_" + a).val()); r++) {
					var lineTa = $("#classa_" + a + "_" + r).val();
					if (lineTa != "" && objClass[lineTa]) {
						alert("商品類別重覆,請重新輸入!!!");
						$("#classa_" + a + "_" + r).focus();
						return false;
					} else {
						objClass[lineTa] = { flag: true, idx: r };
					}
				}
			}

			//附註檢查
			if ($("#O_item11").val() == "" && $("input[name=O_item12]").prop("checked").length > 0) {
				if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
					settab("#tran");
					$("#O_item11").focus();
					return false;
				}
			}
			break;
		
		case "FD2": case "FD3":
			//出名代理人檢查
			if (main.chkAgt("apnum", "apclass", "ttg2_agt_no") == false) return false;

			if (IsEmpty($("#tot_num2").val())) {
				alert("請輸入分割件數");
				settab("#tran");
				$("#tot_num2").focus();
				return false;
			} else {
				$("#nfy_tot_num").val($("#tot_num2").val());
			}

			if ($("#ttz2_Z2").prop("checked") == true) {
				if ($("#ttz2_Z2C").val() == "") {
					alert("附件二有勾選，請輸入按分割件數之分割申請書副本份數");
					settab("#tran");
					$("#ttz2_Z2C").focus();
				}
			}
			//***指定類別數目檢查
			var inputCount = $("[id^='FD2_class_count_'][value!='']").length;//有輸入類別的件數
			if (inputCount == 0) {
				alert("有分割件數，但無輸入分割商品/服務類別、名稱、證明內容及標的，請輸入！！！");
				settab("#tran");
				$("#FD2_class_count_1").focus();
				return false;
			}

			if (CInt($("#tot_num2").val()) != 0) {
				var pname = CInt($("#tot_num2").val());//分割為N件
				var kname = $("[id^='FD2_class_count_'][value!='']").length;//有輸入類別的件數
				if (pname != kname) {//有輸入類別的件數
					var answer = "分割件數(共 " + pname + " 類)與輸入分割後類別項目(共 " + kname + " 類)不符，\n是否確定分割後類別項目共 " + kname + " 類？";
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
				var class_cnt = $("#FD2_class_count_" + a).length;//該分割輸入的共N類
				var input_cnt = $("[id^='classb_" + a + "_'][value!='']").length;//該分割實際有輸入的類別數量

				if (class_cnt != input_cnt) {
					var answer = "分割後指定使用商品類別項目" + a + "(共 " + class_cnt + " 類)與輸入指定使用商品(共 " + input_cnt + " 類)不符，\n是否確定指定使用商品共 " + input_cnt + " 類？";
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
					alert("請選擇分割" + NumberToCh(a) + "名稱種類：");
					settab("#tran");
					$("input[name='FD2_Markb_" + a + "']").eq(0).focus();
					return false;
				}

				//檢查指定類別有無重覆
				var objClass = {};
				for (var r = 1; r <= CInt($("#FD2_class_count_" + a).val()); r++) {
					var lineTa = $("#classb_" + a + "_" + r).val();
					if (lineTa != "" && objClass[lineTa]) {
						alert("商品類別重覆,請重新輸入!!!");
						$("#classb_" + a + "_" + r).focus();
						return false;
					} else {
						objClass[lineTa] = { flag: true, idx: r };
					}
				}
			}

			//附註檢查
			if ($("#O_item21").val() == "" && $("input[name=O_item22]").prop("checked").length > 0) {
				if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
					settab("#tran");
					$("#O_item21").focus();
					return false;
				}
			}
			break;
	}

	//結案復案檢查
	if (main.chkEndBack() == false) return false;

	//檢查大陸案請款註記檢查&給值
	if (main.chkAr() == false) return false;
	
	$("#F_tscode,#tfzd_Tcn_mark").unlock();

	return true;
}