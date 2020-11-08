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

	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfzd_agt_no") == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");
	$("#tfzd_Pul").val($("#tfzy_Pul").val());
    $("#tfzd_Zname_type").val($("#tfzy_Zname_type").val());
    $("#tfzd_prior_country").val($("#tfzy_prior_country").val());	
	
    //主檔商品類別檢查
    if (main.chkGood() == false) return false;
	
    //結案復案檢查
    if (main.chkEndBack() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;

	$("#F_tscode,#tfzd_Tcn_mark").unlock();
    $("#tfg1_seq").val($("#tfzb_seq").val());
    $("#tfg1_seq1").val($("#tfzb_seq1").val());

	//reg.action="Brt11AddAC.asp"	
    //$("#submittask").val("Add");
	//If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	//reg.Submit
}