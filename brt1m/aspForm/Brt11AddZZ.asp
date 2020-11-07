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

if left(reg.tfy_arcase.value,3)="FOB" then
	if trim(reg.tfg1_other_item.value)=empty then
		msgbox "影印內容沒有勾選，請輸入!!"
		settab 6
		reg.ttz1_P1.focus
		exit Function 
	End if
	IF reg.fr_Mark(0).checked=true then
		reg.tfzd_Mark.value=reg.fr_Mark(0).value
	ElseIF reg.fr_Mark(1).checked=true then
		reg.tfzd_Mark.value=reg.fr_Mark(1).value
	ElseIF reg.fr_Mark(2).checked=true then
		reg.tfzd_Mark.value=reg.fr_Mark(2).value
	End IF
end if
IF left(reg.tfy_arcase.value,3)="AD7" then
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "請輸入申請舉行聽證之案件種類!!"
		settab 7
		reg.fr4_remark3(0).focus
		exit function
	Else
		IF reg.fr4_remark3(0).checked=true then
			reg.tfzd_remark3.value=reg.fr4_remark3(0).value
		ElseIF reg.fr4_remark3(1).checked=true then
			reg.tfzd_remark3.value=reg.fr4_remark3(1).value
		ElseIF reg.fr4_remark3(2).checked=true then
			reg.tfzd_remark3.value=reg.fr4_remark3(2).value	
		End IF	
	End IF
	IF reg.fr4_Mark(0).checked=false and reg.fr4_Mark(1).checked=false then
		msgbox "請輸入申請人種類!!"
		settab 7
		reg.fr4_Mark(0).focus
		exit function
	Else
		IF reg.fr4_Mark(0).checked=true then
			reg.tfzd_Mark.value=reg.fr4_Mark(0).value
		ElseIF reg.fr4_Mark(1).checked=true then
			reg.tfzd_Mark.value=reg.fr4_Mark(1).value
		End IF
	End IF
	IF reg.fr4_tran_mark(0).checked=false and reg.fr4_tran_mark(1).checked=false then
		msgbox "請輸入對照當事人種類!!"
		settab 7
		reg.fr4_tran_mark(0).focus
		exit function
	End IF
	for k=1 to reg.de1_apnum.value   
		IF eval("reg.tfr4_ncname1_" & k & ".value")=empty then
			msgbox "請輸入對照當事人名稱!!"
			settab 9
			exit function
		End IF
	next	
	IF reg.fr4_tran_remark1.value=empty then
		msgbox "請輸入應舉行聽證之理由!!"
		settab 7
		reg.fr4_tran_remark1.focus
		exit function
	End IF
ElseIF left(reg.tfy_arcase.value,3)="AD8" then
	
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "請輸入申請舉行聽證之案件種類!!"
		settab 7
		reg.fr4_remark3(0).focus
		exit function
	Else
		IF reg.fr4_remark3(0).checked=true then
			reg.tfzd_remark3.value=reg.fr4_remark3(0).value
		ElseIF reg.fr4_remark3(1).checked=true then
			reg.tfzd_remark3.value=reg.fr4_remark3(1).value
		ElseIF reg.fr4_remark3(2).checked=true then
			reg.tfzd_remark3.value=reg.fr4_remark3(2).value	
		End IF	
	End IF
	IF reg.fr4_Mark(0).checked=false and reg.fr4_Mark(1).checked=false and reg.fr4_Mark(2).checked=false then
		msgbox "請輸入申請人種類!!"
		settab 7
		reg.fr4_Mark(0).focus
		exit function
	Else
		IF reg.fr4_Mark(0).checked=true then
			reg.tfzd_Mark.value=reg.fr4_Mark(0).value
		ElseIF reg.fr4_Mark(1).checked=true then
			reg.tfzd_Mark.value=reg.fr4_Mark(1).value
		ElseIF reg.fr4_Mark(2).checked=true then
			reg.tfzd_Mark.value=reg.fr4_Mark(2).value
		End IF
	End IF
	IF reg.fr4_tran_remark1.value=empty then
		msgbox "請輸入新事證及陳述意見書!!"
		settab 7
		reg.fr4_tran_remark1.focus
		exit function
	End IF
End IF
'申請退費檢查
if left(reg.tfy_arcase.value,3)="FOF" then
   if reg.tfzf_other_item.value=empty then
      msgbox "請輸入國庫支票抬頭名稱！！"
      settab 8
      reg.tfzf_other_item.focus
      exit function
   end if
   if reg.tfzf_debit_money.value=empty then
      msgbox "請輸入退費金額！！"
      settab 8
      reg.tfzf_debit_money.focus
      exit function
   else
      if not isnumeric(reg.tfzf_debit_money.value) then
         msgbox "退費金額必須為數值，請重新輸入！！"
		 settab 8
         reg.tfzf_debit_money.focus
         exit function
      end if
   end if
   if reg.tfzf_other_item1.value=empty then
      msgbox "請輸入規費收據號碼！！"
      settab 8
      reg.tfzf_other_item1.focus
      exit function
   end if
   if reg.tfzf_other_item2.value=empty then
	  <%if not((HTProgRight AND 256) <> 0) then%>'20190613增加 權限C可不輸入退費函字號
      msgbox "請輸入本局通知退費函字號！！"
      settab 8
      reg.ttzf_f1(0).focus
      exit function
	  <%end if%>
   else
      if reg.ttzf_f1(0).checked then
         if reg.f1_yy.value=empty or reg.f1_word.value=empty or reg.f1_no.value=empty then
            msgbox "請輸入本局通知退費函字號！！"
			settab 8
			reg.f1_yy.focus
			exit function
		 end if 	
      end if   
      if reg.ttzf_f1(1).checked then
         if reg.f2_yy.value=empty or reg.f2_word.value=empty or reg.f2_no.value=empty then
            msgbox "請輸入本局通知退費函字號！！"
			settab 8
			reg.f2_yy.focus
			exit function
		 end if 	
      end if   
   end if
   IF reg.frf_Mark(0).checked=true then
		reg.tfzd_Mark.value=reg.frf_Mark(0).value
	ElseIF reg.frf_Mark(1).checked=true then
		reg.tfzd_Mark.value=reg.frf_Mark(1).value
	End IF
end if
'申請補送文件檢查
if left(reg.tfy_arcase.value,3)="FB7" then
	
   if reg.tfb7_other_item.value=empty then
      msgbox "請勾選補送文件！"
      exit function
   end if
end if
'申請撤回申請檢查
if left(reg.tfy_arcase.value,3)="FW1" then
   if reg.tfw1_mod_claim1.checked=false then
      msgbox "請勾選「本申請案自請撤回」"
      exit function
   end if
end if

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false
    reg.submitTask.value = "ADD"
	if reg.tfzb_seq.value = "" then
	   reg.tfg1_seq.value = "null"
	else
	   reg.tfg1_seq.value = reg.tfzb_seq.value
	end if   
	reg.tfg1_seq1.value= reg.tfzb_seq1.value	
	
	if left(reg.tfy_arcase.value,3)="FOB" then
		//出名代理人檢查
		if (main.chkAgt("apnum","apclass","tfg2_agt_no1") == false) return false;
	elseIF left(reg.tfy_arcase.value,3)="AD7" or left(reg.tfy_arcase.value,3)="AD8" then
		//出名代理人檢查
		if (main.chkAgt("apnum","apclass","tfp4_agt_no") == false) return false;
	elseIF left(reg.tfy_arcase.value,3)="FOF" then
		//出名代理人檢查
		if (main.chkAgt("apnum","apclass","tfzf_agt_no1") == false) return false;
	elseIF left(reg.tfy_arcase.value,3)="FB7" then
		//出名代理人檢查
		if (main.chkAgt("apnum","apclass","tfb7_agt_no1") == false) return false;
	Else
		//出名代理人檢查
		if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;
	end if
 
	reg.action="Brt11AddZZ.asp"	
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
