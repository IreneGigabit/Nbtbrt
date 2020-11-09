main.savechkA7 = function () {
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
	var errName = "", errName1 = "";
	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		errName = "授權起日";
		errName1 = "授權迄日";
	} else {
		errName = "終止日期";
	}
	if ($("#tfg1_term1").val() == "") {
		if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
			|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
		) {
			if ($("input[name='tfg1_mod_claim1']").eq(0).prop("checked") == true) {
				alert(errName + "不得為空白,請重新輸入!!");
				settab("#tran");
				$("#tfg1_term1").focus();
				return false;
			}
		} else {
			alert(errName + "不得為空白,請重新輸入!!");
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
				alert(errName1 + "不得為空白,請重新輸入!!");
				settab("#tran");
				$("#tfg1_term2").focus();
				return false;
			}
		}
	}

	//點選無截止日種類之檢查
	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		if ($("input[name='tfg1_mod_claim1']").eq(1).prop("checked") == true) {
			if ($("#fl_term1").val() == "") {
				alert(errName + "不得為空白,請重新輸入!!");
				settab("#tran");
				$("#fl_term1").focus();
				return false;
			}
			$("#tfg1_term1").val($("#fl_term1").val());
		}
	}

	if ($("input[name=tfzd_Mark]").prop("checked").length == 0) {
		alert("請輸入申請人!!");
		settab("#tran");
		$("input[name='tfzd_Mark']").eq(0).focus();
		return false;
	}

	//***授權商品
	if ($("#tfy_Arcase").val().Left(3) == "FL1" || $("#tfy_Arcase").val().Left(3) == "FL2"
		|| $("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6"
	) {
		if ($("input[name=tfl1_mod_type]").prop("checked").length == 0) {
			alert("請選擇授權商品為全部授權或部份授權!!");
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

	//附註檢查
	if ($("#O_item1").val() == "" && $("input[name=O_item2]").prop("checked").length > 0) {
		if (confirm("附註資料中日期未輸入，確定存檔?") == false) {
			settab("#tran");
			$("#O_item1").focus();
			return false;
		}
	}
	//出名代理人檢查
	if (main.chkAgt("apnum", "apclass", "tfg1_agt_no1") == false) return false;

	//結案復案檢查
	if (main.chkEndBack() == false) return false;

	//授權多件檢查
	if ($("#tfy_Arcase").val().Left(3) == "FL5" || $("#tfy_Arcase").val().Left(3) == "FL6") {
		var title_name = "";
		if ($("#tfy_Arcase").val().Left(3) == "FL5") { title_name = "授權"; } else { title_name = "被授權"; }
		if (CInt($("#tot_num21").val()) <= 1) {
			alert(title_name + "案件請輸入多筆!!!");
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
			var answer = title_name + "件數(共 " + tot_num + " 類)與包含主要案性輸入件數(共 " + ctrlcnt + " 類)不符，\n是否確定指定件數共 " + ctrlcnt + " 件？";
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
					alert("本所編號" + x + "變動過，請按[確定]按鈕，重新抓取資料!!!");
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