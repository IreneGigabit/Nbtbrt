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

'****備註日期
select case left(reg.tfy_arcase.value,3)
case "DR1"
	'2013/12/12複製下一筆，案件名稱及註冊號，如未修改就存檔，資料空白，所以再給一次值
	reg.tfzd_appl_name.value=reg.fr1_appl_name.value
	reg.tfzd_issue_no.value=reg.fr1_issue_no.value
	if reg.tfp1_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "本案件為大陸案, 請款註記請設定為大陸進口案!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfp1_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!", 64, "Sorry!" 
		settab 6
		reg.tfp1_seq1.focus 
		Exit function
	end if
	IF reg.R_O_item1.value<>empty or reg.R_O_item2.value<>empty or reg.R_O_item3.value<>empty then
		reg.tfz1_other_item.value=reg.R_O_item1.value&";"&reg.R_O_item2.value&";"&reg.R_O_item3.value
	End IF
	if trim(reg.ttg11_mod_pul_new_no.value) <> empty or trim(reg.ttg11_mod_pul_ncname1.value)<>empty  then
		if reg.ttg11_mod_pul_mod_type(0).checked=false and reg.ttg11_mod_pul_mod_type(1).checked=false then
			msgbox "第"&reg.ttg11_mod_pul_new_no.value&"號「"&reg.ttg11_mod_pul_ncname1.value&"」有輸入資料，請選擇商標或標章，如不選擇，請將輸入資料清空！"
			settab 6
			reg.ttg11_mod_pul_mod_type(0).focus
			exit function
		End IF
	End IF
	if trim(reg.ttg13_mod_pul_new_no.value) <> empty or trim(reg.ttg13_mod_pul_mod_dclass.value) <> empty then
		if reg.ttg13_mod_pul_mod_type.checked=false then
			msgbox "指定使用於商標法施行細則第"&reg.ttg13_mod_pul_new_no.value&"條第"&reg.ttg13_mod_pul_mod_dclass.value&"類商品／服務之註冊應予廢止有輸入資料，請勾選，如不勾選，請將輸入資料清空！"
			settab 6
			reg.ttg13_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	if trim(reg.ttg14_mod_pul_new_no.value) <> empty or trim(reg.ttg14_mod_pul_mod_dclass.value) <> empty or trim(reg.ttg14_mod_pul_ncname1.value)<>empty  then
		if reg.ttg14_mod_pul_mod_type.checked=false then
			msgbox "指定使用於商標法施行細則第"&reg.ttg14_mod_pul_new_no.value&"條第"&reg.ttg14_mod_pul_mod_dclass.value&"類"&reg.ttg14_mod_pul_ncname1.value&"商品／服務之商標權應予廢止有輸入資料，請勾選，如不勾選，請將輸入資料清空！"
			settab 6
			reg.ttg14_mod_pul_mod_type.focus
			exit function
		End IF
	End IF

	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfp1_agt_no") == false) return false;

	'2012/10/3增加廢止商標包含部份，因2012/7/1新申請書修改
	IF reg.R_cappl_name.checked=True then
		reg.tfzd_cappl_name.value=reg.R_cappl_name.value
	Else
		reg.tfzd_cappl_name.value=""
	End IF
	IF reg.R_eappl_name.checked=True then
		reg.tfzd_eappl_name.value=reg.R_eappl_name.value
	Else
		reg.tfzd_eappl_name.value=""
	End IF
	
	IF reg.R_jappl_name.checked=True then
		reg.tfzd_jappl_name.value=reg.R_jappl_name.value
	Else
		reg.tfzd_jappl_name.value=""
	End IF
	IF reg.R_draw.checked=True then
		reg.tfzd_draw.value=reg.R_draw.value
	Else
		reg.tfzd_draw.value=""
	End IF
	IF reg.R_zappl_name1.checked=True then
		reg.tfzd_zappl_name1.value=reg.R_zappl_name1.value
	Else
		reg.tfzd_zappl_name1.value=""
	End IF
	IF reg.R_remark3.value<>empty then
		reg.tfzd_remark3.value=reg.R_remark3.value
	Else
		reg.tfzd_remark3.value=""
	End IF
	
	reg.draw_file.value=reg.tfp1_draw_file.value
	if reg.fr1_class_type(0).checked then reg.tfzr_class_type(0).checked=true
	if reg.fr1_class_type(1).checked then reg.tfzr_class_type(1).checked=true
	
	'reg.tfzb_seq.value = "null"
	'reg.tfzb_seq1.value = "_"
	reg.tfy_case_stat.value = reg.tfp1_case_stat.value
	if reg.tfy_case_stat.value = "NN" then
	   reg.tfzb_seq.value = reg.tfp1_seq.value
	   reg.tfzb_seq1.value = reg.tfp1_seq1.value
	elseif reg.tfy_case_stat.value = "SN" then   
	   reg.tfzb_seq.value = reg.tfp1_New_Ass_seq.value
	   reg.tfzb_seq1.value = reg.tfp1_New_Ass_seq1.value
	   If reg.tfp1_New_Ass_seq.value = empty then
		   msgbox "案件編號不得為空白，請重新輸入"
		   settab 6
		   reg.tfp1_New_Ass_seq.focus
		   exit Function
		End if
		If reg.tfp1_New_Ass_seq1.value = empty then
		   msgbox "案件編號副碼不得為空白，請重新輸入"
		   settab 6
		   reg.tfp1_New_Ass_seq1.focus
		   exit Function
		End if
	end if
	
case "DO1"
	'2013/12/12複製下一筆，案件名稱及註冊號，如未修改就存檔，資料空白，所以再給一次值
	reg.tfzd_appl_name.value=reg.fr2_appl_name.value
	reg.tfzd_issue_no.value=reg.fr2_issue_no.value
	if reg.tfp2_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "本案件為大陸案, 請款註記請設定為大陸進口案!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfp2_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!", 64, "Sorry!" 
		settab 5
		reg.tfp2_seq1.focus 
		Exit function
	end if
	IF reg.O_O_item1.value<>empty or reg.O_O_item2.value<>empty or reg.O_O_item3.value<>empty then
		reg.tfz2_other_item.value=reg.O_O_item1.value&";"&reg.O_O_item2.value&";"&reg.O_O_item3.value
	End IF
	if trim(reg.ttg21_mod_pul_new_no.value) <> empty or trim(reg.ttg21_mod_pul_ncname1.value)<>empty  then
		if reg.ttg21_mod_pul_mod_type(0).checked=false and reg.ttg21_mod_pul_mod_type(1).checked=false then
			msgbox "第"&reg.ttg21_mod_pul_new_no.value&"號「"&reg.ttg21_mod_pul_ncname1.value&"類」有輸入資料，請選擇商標或標章，如不選擇，請將輸入資料清空！"
			settab 5
			reg.ttg21_mod_pul_mod_type(0).focus
			exit function
		End IF
	End IF
	if trim(reg.ttg23_mod_pul_new_no.value) <> empty or trim(reg.ttg23_mod_pul_mod_dclass.value) <> empty then
		if reg.ttg23_mod_pul_mod_type.checked=false then
			msgbox "指定使用於商標法施行細則第"&reg.ttg23_mod_pul_new_no.value&"條第"&reg.ttg23_mod_pul_mod_dclass.value&"類商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！"
			settab 5
			reg.ttg23_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	if trim(reg.ttg24_mod_pul_new_no.value) <> empty or trim(reg.ttg24_mod_pul_mod_dclass.value) <> empty or trim(reg.ttg24_mod_pul_ncname1.value)<>empty  then
		if reg.ttg24_mod_pul_mod_type.checked=false then
			msgbox "指定使用於商標法施行細則第"&reg.ttg24_mod_pul_new_no.value&"條第"&reg.ttg24_mod_pul_mod_dclass.value&"類"&reg.ttg24_mod_pul_ncname1.value&"商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！"
			settab 5
			reg.ttg24_mod_pul_mod_type.focus
			exit function
		End IF
	End IF

	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfp2_agt_no") == false) return false;

	IF reg.O_cappl_name.checked=True then
		reg.tfzd_cappl_name.value=reg.O_cappl_name.value
	Else
		reg.tfzd_cappl_name.value=""
	End IF
	IF reg.O_eappl_name.checked=True then
		reg.tfzd_eappl_name.value=reg.O_eappl_name.value
	Else
		reg.tfzd_eappl_name.value=""
	End IF
	
	IF reg.O_jappl_name.checked=True then
		reg.tfzd_jappl_name.value=reg.O_jappl_name.value
	Else
		reg.tfzd_jappl_name.value=""
	End IF
	IF reg.O_draw.checked=True then
		reg.tfzd_draw.value=reg.O_draw.value
	Else
		reg.tfzd_draw.value=""
	End IF
	IF reg.O_zappl_name1.checked=True then
		reg.tfzd_zappl_name1.value=reg.O_zappl_name1.value
	Else
		reg.tfzd_zappl_name1.value=""
	End IF
	IF reg.O_remark3.value<>empty then
		reg.tfzd_remark3.value=reg.O_remark3.value
	Else
		reg.tfzd_remark3.value=""
	End IF
	reg.draw_file.value=reg.tfp2_draw_file.value					
	if reg.fr2_class_type(0).checked then reg.tfzr_class_type(0).checked=true
	if reg.fr2_class_type(1).checked then reg.tfzr_class_type(1).checked=true	
	'reg.tfzb_seq.value = "null"
	'reg.tfzb_seq1.value = "_"
	
	reg.tfy_case_stat.value = reg.tfp2_case_stat.value
	if reg.tfy_case_stat.value = "NN" then
	   reg.tfzb_seq.value = reg.tfp2_seq.value
	   reg.tfzb_seq1.value = reg.tfp2_seq1.value
	elseif reg.tfy_case_stat.value = "SN" then   
	   reg.tfzb_seq.value = reg.tfp2_New_Ass_seq.value
	   reg.tfzb_seq1.value = reg.tfp2_New_Ass_seq1.value
	   If reg.tfp2_New_Ass_seq.value = empty then
		   msgbox "案件編號不得為空白，請重新輸入"
		   settab 5
		   reg.tfp2_New_Ass_seq.focus
		   exit Function
		End if
		If reg.tfp2_New_Ass_seq1.value = empty then
		   msgbox "案件編號副碼不得為空白，請重新輸入"
		   settab 5
		   reg.tfp2_New_Ass_seq1.focus
		   exit Function
		End if
	end if			
case "DI1"
	'2013/12/12複製下一筆，案件名稱及註冊號，如未修改就存檔，資料空白，所以再給一次值
	reg.tfzd_appl_name.value=reg.fr3_appl_name.value
	reg.tfzd_issue_no.value=reg.fr3_issue_no.value
	if reg.tfp3_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "本案件為大陸案, 請款註記請設定為大陸進口案!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfp3_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!", 64, "Sorry!" 
		settab 7
		reg.tfp3_seq1.focus 
		Exit function
	end if
	IF reg.I_O_item1.value<>empty or reg.I_O_item2.value<>empty or reg.I_O_item3.value<>empty then
		reg.tfz3_other_item.value=reg.I_O_item1.value&";"&reg.I_O_item2.value&";"&reg.I_O_item3.value
	End IF
	if trim(reg.ttg31_mod_pul_new_no.value) <> empty or trim(reg.ttg31_mod_pul_ncname1.value)<>empty  then
		if reg.ttg31_mod_pul_mod_type(0).checked=false and reg.ttg31_mod_pul_mod_type(1).checked=false then
			msgbox "第"&reg.ttg31_mod_pul_new_no.value&"號「"&reg.ttg31_mod_pul_ncname1.value&"類」有輸入資料，請選擇商標或標章，如不選擇，請將輸入資料清空！"
			settab 7
			reg.ttg31_mod_pul_mod_type(0).focus
			exit function
		End IF
	End IF
	if trim(reg.ttg33_mod_pul_new_no.value) <> empty or trim(reg.ttg33_mod_pul_mod_dclass.value) <> empty then
		if reg.ttg33_mod_pul_mod_type.checked=false then
			msgbox "指定使用於商標法施行細則第"&reg.ttg33_mod_pul_new_no.value&"條第"&reg.ttg33_mod_pul_mod_dclass.value&"類商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！"
			settab 7
			reg.ttg33_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	if trim(reg.ttg34_mod_pul_new_no.value) <> empty or trim(reg.ttg34_mod_pul_mod_dclass.value) <> empty or trim(reg.ttg34_mod_pul_ncname1.value)<>empty  then
		if reg.ttg34_mod_pul_mod_type.checked=false then
			msgbox "指定使用於商標法施行細則第"&reg.ttg34_mod_pul_new_no.value&"條第"&reg.ttg34_mod_pul_mod_dclass.value&"類"&reg.ttg34_mod_pul_ncname1.value&"商品／服務之註冊應予撤銷有輸入資料，請勾選，如不勾選，請將輸入資料清空！"
			settab 7
			reg.ttg34_mod_pul_mod_type.focus
			exit function
		End IF
	End IF

	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfp3_agt_no") == false) return false;

	IF reg.I_cappl_name.checked=True then
		reg.tfzd_cappl_name.value=reg.I_cappl_name.value
	else
		reg.tfzd_cappl_name.value=""
	End IF
	IF reg.I_eappl_name.checked=True then
		reg.tfzd_eappl_name.value=reg.I_eappl_name.value
	else
		reg.tfzd_eappl_name.value=""
	End IF
	IF reg.I_jappl_name.checked=True then
		reg.tfzd_jappl_name.value=reg.I_jappl_name.value
	else
		reg.tfzd_jappl_name.value=""		
	End IF
	IF reg.I_draw.checked=True then
		reg.tfzd_draw.value=reg.I_draw.value
	Else
		reg.tfzd_draw.value=""
	End IF
	IF reg.I_zappl_name1.checked=True then
		reg.tfzd_zappl_name1.value=reg.I_zappl_name1.value
	Else
		reg.tfzd_zappl_name1.value=""
	End IF
	IF reg.I_remark3.value<>empty then
		reg.tfzd_remark3.value=reg.I_remark3.value
	else
		reg.tfzd_remark3.value=""
	End IF
	IF reg.I_item1(0).checked=true or reg.I_item1(1).checked=true or reg.I_item1(2).checked=true then 'or reg.I_item2.value<>empty then
		'2013/1/24因應商標法修正改為多選
		pother_item1=""
		if reg.I_item1(0).checked=true then
		   pother_item1=reg.I_item1(0).value 
		end if
		if reg.I_item1(1).checked=true then
		    if pother_item1<>"" then
			   pother_item1=pother_item1 & "|" & reg.I_item1(1).value 
			else
			   pother_item1=reg.I_item1(1).value   
			end if
	    end if
	    if reg.I_item1(2).checked=true then
		    if pother_item1<>"" then
			   pother_item1=pother_item1 & "|" & reg.I_item1(2).value 
			else
			   pother_item1=reg.I_item1(2).value   
			end if
	    end if 
	    if reg.I_item1(0).checked=true or reg.I_item1(1).checked=true then 
	       pother_item1=pother_item1 & ";"&reg.I_item2.value
	       if reg.I_item1(2).checked=true then 
	          pother_item1=pother_item1 & "|"&reg.I_item2t.value
	       end if   
	    elseif reg.I_item1(2).checked=true then 
	       pother_item1=pother_item1 & ";"&reg.I_item2t.value
	    end if
	    reg.tfz3_other_item1.value=pother_item1
	else
		reg.tfz3_other_item1.value=""
	End IF
	reg.draw_file.value=reg.tfp3_draw_file.value					
if reg.fr3_class_type(0).checked then reg.tfzr_class_type(0).checked=true
	if reg.fr3_class_type(1).checked then reg.tfzr_class_type(1).checked=true	
	'reg.tfzb_seq.value = "null"
	'reg.tfzb_seq1.value = "_"
	
	reg.tfy_case_stat.value = reg.tfp3_case_stat.value
	if reg.tfy_case_stat.value = "NN" then
	   reg.tfzb_seq.value = reg.tfp3_seq.value
	   reg.tfzb_seq1.value = reg.tfp3_seq1.value
	elseif reg.tfy_case_stat.value = "SN" then   
	   reg.tfzb_seq.value = reg.tfp3_New_Ass_seq.value
	   reg.tfzb_seq1.value = reg.tfp3_New_Ass_seq1.value
	   If reg.tfp3_New_Ass_seq.value = empty then
		   msgbox "案件編號不得為空白，請重新輸入"
		   settab 7
		   reg.tfp3_New_Ass_seq.focus
		   exit Function
		End if
		If reg.tfp3_New_Ass_seq1.value = empty then
		   msgbox "案件編號副碼不得為空白，請重新輸入"
		   settab 7
		   reg.tfp3_New_Ass_seq1.focus
		   exit Function
		End if
	end if
case else
	If reg.tfy_case_stat.value="NN" then
		'reg.tfzb_seq.value = "null"
		reg.tfzb_seq.value = reg.New_seq.value
		reg.tfzb_seq1.value = reg.New_seq1.value
	Elseif reg.tfy_case_stat.value="SN" then
		reg.tfzb_seq.value = reg.New_Ass_seq.value
		reg.tfzb_seq1.value = reg.New_Ass_seq1.value
		If reg.New_Ass_seq.value = empty then
		   msgbox "案件編號不得為空白，請重新輸入"
		   settab 4
		   reg.New_Ass_seq.focus
		   exit Function
		End if
		If reg.New_Ass_seq1.value = empty then
		   msgbox "案件編號副碼不得為空白，請重新輸入"
		   settab 4
		   reg.New_Ass_seq1.focus
		   exit Function
		End if
	Elseif	reg.tfy_case_stat.value="OO" then
		reg.tfzb_seq.value = reg.Old_seq.value
		reg.tfzb_seq1.value = reg.Old_seq1.value
		If reg.Old_seq.value = empty then
		   msgbox "當案件為舊案時，請輸入『案件編號』及按下『確定』以取得詳細資料!"
		   settab 4
		   reg.Old_seq.focus
		   exit Function
		End if							
	End if
	'大陸案請款註記檢查
	if reg.tfzb_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "本案件為大陸案, 請款註記請設定為大陸進口案!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfzb_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!", 64, "Sorry!" 
		settab 4
		If reg.tfy_case_stat.value="NN" then	
			reg.new_seq1.focus 
		Elseif	reg.tfy_case_stat.value="OO" then
			reg.old_seq1.focus 
		End if
		Exit function
	end if
	if left(reg.tfy_arcase.value,3)<>"DE1" and left(reg.tfy_arcase.value,3)<>"DE2" then
		//出名代理人檢查
		if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;
	end if	
End Select
'案件內容
IF left(reg.tfy_arcase.value,3)="DE1" then
	
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "請輸入申請舉行聽證之案件種類!!"
		settab 9
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
	'IF reg.fr4_Mark(0).checked=false and reg.fr4_Mark(1).checked=false and reg.fr4_Mark(2).checked=false then
	IF reg.fr4_Mark(0).checked=false and reg.fr4_Mark(1).checked=false then
		msgbox "請輸入申請人種類!!"
		settab 9
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
		settab 9
		reg.fr4_tran_mark(0).focus
		exit function
	End IF
	if reg.de1_apnum.value = 0 then
	   msgbox "請輸入對照當事人資料！"
	   settab 9
	   exit function
	end if
	for k=1 to reg.de1_apnum.value   
		IF eval("reg.tfr4_ncname1_" & k & ".value")=empty then
			msgbox "請輸入對照當事人名稱!!"
			settab 9
			exit function
		End IF
	next	
	IF reg.fr4_tran_remark1.value=empty then
		msgbox "請輸入應舉行聽證之理由!!"
		settab 9
		reg.fr4_tran_remark1.focus
		exit function
	End IF

	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfp4_agt_no") == false) return false;

ElseIF left(reg.tfy_arcase.value,3)="DE2" then
	
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "請輸入申請舉行聽證之案件種類!!"
		settab 9
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
	IF reg.fr4_Mark(0).checked=false and reg.fr4_Mark(1).checked=false and reg.fr4_Mark(2).checked=false  then
		msgbox "請輸入申請人種類!!"
		settab 9
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
		settab 9
		reg.fr4_tran_remark1.focus
		exit function
	End IF

	//出名代理人檢查
	if (main.chkAgt("apnum","apclass","tfp4_agt_no") == false) return false;
End IF
'***end***
main.chkEndBack()
	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");
	
	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value

'2010/10/4異議、評定及廢止增加記錄類別，不用檢查類別及其商品資料，但需檢查類別數與輸入費用類數是否相同
IF left(reg.tfy_arcase.value,3)="DO1" or left(reg.tfy_arcase.value,3)="DI1" or left(reg.tfy_arcase.value,3)="DR1" then
	'2010/10/8類別檢查，至少輸入一類
	parcase=left(reg.tfy_arcase.value,3)
	ptab_num=3	'tab數
	sclass_count=1	'收費標準類別數，基準值=1
	select case parcase
	   case "DR1"
	        pname="fr1_class"
	        pclass=reg.fr1_class.value
	        pclass_count=reg.fr1_class_count.value
	        ptab_num=6
	        for w=1 to 5
	            if eval("reg.nfyi_item_arcase"&w&".value")="DR1B" then
	               sclass_count=sclass_count + eval("reg.nfyi_item_count"&w&".value")
	               exit for
	            end if
	        next
	   case "DO1"
		    pname="fr2_class"
		    pclass=reg.fr2_class.value
		    pclass_count=reg.fr2_class_count.value
		    ptab_num=5
		    for w=1 to 5
	            if eval("reg.nfyi_item_arcase"&w&".value")="DO1B" then
	               sclass_count=sclass_count + eval("reg.nfyi_item_count"&w&".value")
	               exit for
	            end if
	        next
	   case "DI1"
			pname="fr3_class"
			pclass=reg.fr3_class.value
			pclass_count=reg.fr3_class_count.value
			ptab_num=7
			for w=1 to 5
	            if eval("reg.nfyi_item_arcase"&w&".value")="DI1B" then
	               sclass_count=sclass_count + eval("reg.nfyi_item_count"&w&".value")
	               exit for
	            end if
	        next
	end select
	if pclass="" or pclass=empty then
	   msgbox "請輸入類別資料！"
	   settab ptab_num
	   execute "reg." & pname & ".focus"
	   exit function
	end if
	if cint(pclass_count)<>cint(sclass_count) then
	   msgbox "收費提列類別數(共" & sclass_count & "類)與交辦內容類別數(共" & pclass_count & "類)不同，請檢查！"
	   'settab ptab_num
	   'execute "reg." & pname & ".focus"
	   settab 3
	   exit function
	end if
else	
    //主檔商品類別檢查
    if (main.chkGood() == false) return false;
end if	

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

		reg.F_tscode.disabled = false
		reg.tfzd_tcn_mark.disabled = false
		reg.tfg1_seq.value = reg.tfzb_seq.value
		reg.tfg1_seq1.value= reg.tfzb_seq1.value		
   
	reg.action="Brt11AddB.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
