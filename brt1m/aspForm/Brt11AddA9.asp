<%
function formAddSubmit()	
'----- 用戶端Submit前的檢查碼放在這裡 ，如下例 not valid 時 exit sub 離開------------ 
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;
	
    //申請人檢查
    if (main.chkApp() == false) return false;

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢杳"); return false; }

	//商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");
	
	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value
	
    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;



'****總計案性數
	if reg.tfy_arcase.value<>empty then
		reg.nfy_tot_case.value=1
	end if
	for q=1 to 5
		qname="reg.nfyi_item_Arcase"&q&".value"
		if eval(qname)<>empty then
			reg.nfy_tot_case.value=reg.nfy_tot_case.value+1
		end if
	next 	    
'*****案件內容

if left(reg.tfy_arcase.value,3)="FP1" then
	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;

	reg.tfg1_seq.value = reg.tfzb_seq.value
	reg.tfg1_seq1.value= reg.tfzb_seq1.value	
elseif left(reg.tfy_arcase.value,3)="FP2" then
	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;

	reg.tfg2_seq.value = reg.tfzb_seq.value
	reg.tfg2_seq1.value= reg.tfzb_seq1.value	
End iF

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false

	reg.action="Brt11AddA9.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
