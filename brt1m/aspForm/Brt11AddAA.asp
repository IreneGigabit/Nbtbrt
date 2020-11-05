<%
function formAddSubmit()	
'----- 用戶端Submit前的檢查碼放在這裡 ，如下例 not valid 時 exit sub 離開------------ 
main.chkCustAtt();
	
	'申請人檢查
	IF reg.apnum.value=0 then
		msgbox "請輸入申請人資料！！"
		settab 2
		reg.AP_Add_button.focus
		exit function
	End IF
	
	for tapnum=1 to reg.apnum.value
		if eval("reg.Apcust_no"& tapnum &".value") = empty then	
			MsgBox "申請人編號不得為空白！", 64, "Sorry!"
			settab 2
			execute "reg.Apcust_no"& tapnum &".focus"
			Exit function  
		end if
	
		execute "reg.ap_cname"& tapnum &".value = reg.ap_cname1_"& tapnum &".value + reg.ap_cname2_"& tapnum &".value"
		execute "reg.ap_ename"& tapnum &".value = reg.ap_ename1_"& tapnum &".value + reg.ap_ename2_"& tapnum &".value"
		if eval("reg.ap_cname1_"&tapnum&".value")<>empty then
			if fDataLen(eval("reg.ap_cname1_"& tapnum &".value"),44,"申請人名稱(中)")="" then 
				settab 2
			    execute "reg.ap_cname1_"& tapnum &".focus"
				exit function
			end if
		End IF
		if eval("reg.ap_cname2_"& tapnum &".value")<>empty then
			if fDataLen(eval("reg.ap_cname2_"& tapnum &".value"),44,"申請人名稱(中)")="" then
				settab 2
			   execute "reg.ap_cname2_"& tapnum &".focus"
			exit function
			end if
		End IF
		if eval("reg.ap_ename1_"& tapnum &".value")<>empty then
			if fDataLen(eval("reg.ap_ename1_"& tapnum &".value"),100,"申請人名稱(英)")="" then
				settab 2
			   execute "reg.ap_ename1_"& tapnum &".focus"
			exit function
			end if
		End IF
		if eval("reg.ap_ename2_"& tapnum &".value")<>empty then
			if fDataLen(eval("reg.ap_ename2_"& tapnum &".value"),100,"申請人名稱(英)")="" then 
				settab 2
			   execute "reg.ap_ename2_"& tapnum &".focus"
			exit function	
			end if
		End IF
		if reg.tfy_case_stat.value<>"OO" then	'新案
		   '2014/4/22增加檢查是否為雙邊代理查照對象
			if cust_name_chk(eval("reg.ap_cname"& tapnum &".value"),eval("reg.ap_ename"& tapnum &".value"))=true then 
				settab 2
				exit function
			end if   
			if aprep_name_chk(eval("reg.ap_crep"& tapnum &".value"),eval("reg.ap_erep"& tapnum &".value"))=true then 
				settab 2
				exit function
			end if   
		end if
	next
	
    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;


IF reg.tfy_case_stat.value="NN" or reg.tfy_case_stat.value="SN" then
	IF reg.tfzd_Appl_name.value=empty then
		msgbox "商標名稱不可空白！！"
		settab 4
		reg.tfzd_Appl_name.focus
		exit function
	End IF
	'2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
    if check_CustWatch("appl_name",reg.tfzd_Appl_name.value)=true then 
        settab 4
	    reg.tfzd_Appl_name.focus
        exit function  
    end if
End IF		
IF reg.tfy_case_stat.value="OO" then
	IF reg.keyseq.value="N" then
		msgbox "主案件編號變動過，請按[確定]按鈕，重新抓取資料!!!"
		settab 4
		gname="reg.btnseq_ok.focus"
		execute gname
		exit function
	End IF	
End IF	
'優先權申請日檢查
If reg.pfzd_prior_date.value <> empty then
	IF isdate(reg.pfzd_prior_date.value) = false then
		msgbox "請檢查優先權申請日，日期格式是否正確!!"
		settab 4
		reg.pfzd_prior_date.focus
		exit function
	End If
End If 	

'***申請日期
If reg.tfzd_apply_date.value <> empty then
	IF isdate(reg.tfzd_apply_date.value) = false then
		msgbox "請檢查申請日期 ，日期格式是否正確!!"
		settab 4
		reg.tfzd_apply_date.focus
		exit function
	End If
End If 	
'***註冊日期
If reg.tfzd_issue_date.value <> empty then
	IF isdate(reg.tfzd_issue_date.value) = false then
		msgbox "請檢查註冊日期 ，日期格式是否正確!!"
		settab 4
		reg.tfzd_issue_date.focus
		exit function
	End If
End If 	
'***公告日期
If reg.tfzd_open_date.value <> empty then
	IF isdate(reg.tfzd_open_date.value) = false then
		msgbox "請檢查公告日期 ，日期格式是否正確!!"
		settab 4
		reg.tfzd_open_date.focus
		exit function
	End If
End If
'***結案日期
If reg.tfzd_end_date.value <> empty then
	IF isdate(reg.tfzd_end_date.value) = false then
		msgbox "請檢查結案日期 ，日期格式是否正確!!"
		settab 4
		reg.tfzd_end_date.focus
		exit function
	End If
End If
'***專用期限
If reg.tfzd_dmt_term1.value <> empty then
	IF isdate(reg.tfzd_dmt_term1.value) = false then
		msgbox "請檢查專用期限起日 ，日期格式是否正確!!"
		settab 4
		reg.tfzd_dmt_term1.focus
		exit function
	End If
End If 	
'***專用期限
If reg.tfzd_dmt_term2.value <> empty then
	IF isdate(reg.tfzd_dmt_term2.value) = false then
		msgbox "請檢查專用期限迄日 ，日期格式是否正確!!"
		settab 4
		reg.tfzd_dmt_term2.focus
		exit function
	End If
End If 	
'****備註日期
If reg.O_item1.value <> empty then
	IF isdate(reg.O_item1.value) = false then
		msgbox "請檢查備註日期 ，日期格式是否正確!!"
		settab 5
		reg.O_item1.focus
		exit function
	End If
End If 	

IF reg.tfzd_Mark(0).checked=true then 	
	if trim(reg.tfzd_apply_no.value) = empty then	
	    MsgBox "申請號數不可以空白！", 64, "Sorry!"
	    settab 4
	    reg.tfzd_apply_no.focus
	    Exit function  
	end if
ElseIF reg.tfzd_Mark(1).checked=true then
	if trim(reg.tfzd_issue_no.value) = empty then	
	    MsgBox "註冊號數不可以空白！", 64, "Sorry!"
	    settab 4
	    reg.tfzd_issue_no.focus
	    Exit function  
	end if
End IF
	
	
	If reg.tfy_case_stat.value="NN" then
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
		   msgbox "當案件為舊案證明文件時，請輸入『案件編號』及按下『確定』以取得詳細資料!"
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
	'reg.tfzd_appl_name.value = reg.tfzd_cappl_name.value
	if reg.tfzy_color(0).checked=true then
		reg.tfzd_color.value="B"
	elseif reg.tfzy_color(1).checked=true then
		reg.tfzd_color.value="C"
	end if
	if reg.tfzy_s_mark(0).checked=true then
		reg.tfzd_s_mark.value=""
	elseif reg.tfzy_s_mark(1).checked=true then
		reg.tfzd_s_mark.value="S"
	elseif reg.tfzy_s_mark(2).checked=true then
		reg.tfzd_s_mark.value="N"
	elseif reg.tfzy_s_mark(3).checked=true then
		reg.tfzd_s_mark.value="M"
	elseif reg.tfzy_s_mark(4).checked=true then
		reg.tfzd_s_mark.value="L"
	end if
	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value
	
'****指定使用商品/服務類別及名稱
'	gname="reg.tfzr_class.value"
'	kname="reg.tfzr_class_count.value"
'	if eval(gname)= empty or eval(kname) = empty then
'		msgbox "請輸入指定使用商品/服務類別、名稱!!"
'		settab 4
'		execute "reg.tfzr_class_count.focus"
'		exit function
'	end if
'類別檢查
execute "pname=reg.tfzr_class_count.value"	'抓取指定類別總數
IF eval(pname)<>empty then
	'2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
	if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
		for z=1 to eval(pname)
			execute "gname=reg.class1"&z&".value"
			execute "pname=reg.good_name1"&z&".value"
			if pname<>empty and gname=empty  then
				msgbox "請輸入類別!!!"
				settab 4
				execute "reg.class1"&z&".focus"
				exit function
			end if
			if gname<>empty and reg.tfzr_class_type(0).checked then
				if cint(gname) < 0 or cint(gname) > 45 then
					Msgbox "使用類別"&z&"不符國際分類(001~045)。"
					settab 4
					execute "reg.class1"&z&".focus"
					exit function
				end if
			end if
		next		
	end if	
End IF		
'指定類別檢查
execute "pname=reg.tfzr_class_count.value"	'抓取指定類別總數
'2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
	for z=1 to eval(pname)
		for j=1 to eval(pname)
			if z<>j then
				execute "gname=reg.class1"&z&".value"
				execute "kname=reg.class1"&j&".value"
				if gname<>empty  then
					if gname=kname then
					   Msgbox "商品類別重覆,請重新輸入!!!"
					   settab 4
					   execute "reg.class1"&j&".focus"
					   exit function
					end if
				end if
			end if
			execute "kname=reg.class1"&j&".value"
			if kname<>empty and reg.tfzr_class_type(0).checked then
				if cint(kname) < 0 or cint(kname) > 45 then
					Msgbox "使用類別"&j&"不符國際分類(001~045)。"
					settab 4
				    execute "reg.class1"&j&".focus"
					exit function
				end if
			end if
		next
	next	
end if	
'***指定類別數目檢查
if reg.tfzr_class_count.value<>empty then
	kname="reg.tfzr_class_count.value"
	gname="reg.ctrlcount1.value"
	class_cnt=eval(kname)
	ctrlcnt=eval(gname)
	    if class_cnt <> ctrlcnt then
			answer=msgbox("指定使用商品類別項目(共 "&eval(kname)&" 類)與輸入指定使用商品(共 "& eval(gname) &" 類)不符，"&chr(13)&chr(13)&"是否確定指定使用商品共 "& eval(gname) &" 類？",vbYesNo+vbdefaultbutton2,"確認商品類別項目")
			if answer = vbYes then
				execute "reg.tfzr_class_count.value=" & ctrlcnt
			else
				settab 4
				execute "reg.tfzr_class_count.focus"
				exit function
			end if
		end if
end if	
'附註檢查
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false and reg.O_item2(4).checked=false) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true or reg.O_item2(4).checked=true) then
	answer=msgbox("附註資料中日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認附註項目")
			if answer <> vbYes then
				'execute "reg.tfzr_class_count.value=" & ctrlcnt
			'else
				settab 5
				execute "reg.O_item1.focus"
				exit function
			end if
end if

'****請款註記	
if reg.tfzb_seq1.value ="M" then
	reg.tfy_ar_code.value="M"
Elseif reg.nfy_service.value=0 and reg.nfy_fees.value=0 and reg.nfy_oth_money.value=0 and reg.tfy_ar_mark.value="N" then
	reg.tfy_ar_code.value="X"
Else
	reg.tfy_ar_code.value="N"
End IF	


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
if reg.tfgd_mod_claim1(0).checked=false and reg.tfgd_mod_claim1(1).checked=false then
'	msgbox "請點選專用期間/申請註冊日期!!!"
	'2007/9/1新申請書取消專用期間/申請註冊日期，修改為提醒
	'2012/7/1新申請書取消，畫面隱藏，修改不需檢查
	'answer=msgbox("專用期間/申請註冊日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認專用期間/申請註冊日期")
	'if answer = vbNo then
	'   settab 5 
	'   reg.tfgd_mod_claim1(0).focus
	'   exit Function
	'end if   
else
	if reg.tfgd_mod_claim1(0).checked=true then
		If trim(reg.tfn1_term1.value) = empty then
			msgbox "專用起日不得為空白，請重新輸入!!!"
			settab 5
			reg.tfn1_term1.focus
			exit Function
		else
			reg.tfg3_term1.value=reg.tfn1_term1.value
		End if
		If trim(reg.tfn1_term2.value) = empty then
			msgbox "專用迄日不得為空白，請重新輸入!!!"
			settab 5
			reg.tfn1_term2.focus
			exit Function
		else
			reg.tfg3_term2.value=reg.tfn1_term2.value
		End if
	elseif reg.tfgd_mod_claim1(1).checked=true then
		If trim(reg.tfn2_term1.value) = empty then
			msgbox "申請日不得為空白，請重新輸入"
			settab 5
			reg.tfn2_term1.focus
			exit Function
		else
			reg.tfg3_term1.value=reg.tfn2_term1.value
		End if
	end if
end if			
if reg.tfgd_tran_Mark(0).checked=false and reg.tfgd_tran_Mark(1).checked=false then
	msgbox "請輸入證明書種類!!"
	settab 5
	reg.tfgd_tran_Mark(0).focus
	exit Function
end if
v=split(reg.tfy_Arcase.value,"&")
if ubound(v)=2 then
   pagt_no=v(2)
else
   'pagt_no="A05"
   'pagt_no="A07"	'2008/12/16因應98年度出名代理人修改為A07高&楊&林
   'pagt_no="A09"	'2013/7/17因應102年度出名代理人修改為A09高&楊
   pagt_no=get_tagtno("N")	'2015/10/21因應104年度出名代理人修改並改抓取cust_code.code_type=Tagt_no and mark=N預設出名代理人
end if
'出名代理人檢查
apclass_flag="N"
for capnum=1 to reg.apnum.value
	IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
		apclass_flag="C"	
	End IF
next
if apclass_flag="C" then
	  if check_agtno("C",reg.tfgd_agt_no1.value)=true then
	     settab 5
	 	 reg.tfgd_agt_no1.focus
	 	 exit function
	  end if
else	   	 
   if trim(reg.tfgd_agt_no1.value)<>trim(pagt_no) then
      ans=msgbox("出名代理人與案性預設出名代理人不同，是否確定交辦？",vbYesNo+vbdefaultbutton2,"確定出名代理人")
      if ans=vbNo then
         settab 5
         reg.tfgd_agt_no1.focus
         exit function
      end if
   end if   
end if
main.chkEndBack()
	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false
    reg.tfgd_seq.value = reg.tfzb_seq.value
	reg.tfgd_seq1.value= reg.tfzb_seq1.value		
	reg.tfzd_agt_no.value=reg.tfgd_agt_no1.value

'****當無收費標準時，把值清空
	if reg.anfees.value = "N" then 
		reg.nfy_Discount.value =""
		reg.tfy_discount_remark.value=""	'2016/5/30增加折扣理由
	end if	
	reg.action="Brt11AddAA.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
