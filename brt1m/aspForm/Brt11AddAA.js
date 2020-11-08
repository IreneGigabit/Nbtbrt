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

	//附註檢查
	if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
		if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
			settab("#tran");
			$("#O_item1").focus();
			return false;
		}
	}
	
	//檢查大陸案請款註記檢查&給值
	if (main.chkAr() == false) return false;

	//*****案件內容
	if ($("input[name=tfgd_mod_claim1]").eq(0).prop("checked") == true) {
		if (IsEmpty($("#tfn1_term1").val())) {
			alert("專用起日不得為空白，請重新輸入!!!");
			settab("#tran");
			$("#tfn1_term1").focus();
			return false;
		} else {
			$("#tfg3_term1").val($("#tfn1_term1").val());
		}
		if (IsEmpty($("#tfn1_term2").val())) {
			alert("專用迄日不得為空白，請重新輸入!!!");
			settab("#tran");
			$("#tfn1_term2").focus();
			return false;
		} else {
			$("#tfg3_term2").val($("#tfn1_term2").val());
		}
	} else if ($("input[name=tfgd_mod_claim1]").eq(1).prop("checked") == true) {
		if (IsEmpty($("#tfn2_term1").val())) {
			alert("申請日不得為空白，請重新輸入!!!");
			settab("#tran");
			$("#tfn2_term1").focus();
			return false;
		} else {
			$("#tfg3_term1").val($("#tfn2_term1").val());
		}
	}

	if ($("input[name=tfgd_tran_Mark]").prop("checked").length == 0) {
		alert("請輸入證明書種類!!");
		settab("#tran");
		$("input[name=tfgd_tran_Mark]").eq(0).focus();
		return false;
	}
	
	//出名代理人檢查
	if (main.chkAgt("apnum", "apclass", "tfgd_agt_no1") == false) return false;

	//結案復案檢查
	if (main.chkEndBack() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
	$("#tfgd_seq").val($("#tfzb_seq").val());
	$("#tfgd_seq1").val($("#tfzb_seq1").val());

	//reg.action="Brt11AddAA.asp"	
	//$("#submittask").val("Add");
	//If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	//reg.Submit
}