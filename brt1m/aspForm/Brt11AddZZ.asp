<%
function formAddSubmit()	
'----- �Τ��Submit�e���ˬd�X��b�o�� �A�p�U�� not valid �� exit sub ���}------------ 
main.chkCustAtt();
	
	'�ӽФH�ˬd
	IF reg.apnum.value=0 then
		msgbox "�п�J�ӽФH��ơI�I"
		settab 2
		reg.AP_Add_button.focus
		exit function
	End IF
	
	for tapnum=1 to reg.apnum.value
		if eval("reg.Apcust_no"& tapnum &".value") = empty then	
			MsgBox "�ӽФH�s�����o���ťաI", 64, "Sorry!"
			settab 2
			execute "reg.Apcust_no"& tapnum &".focus"
			Exit function  
		end if
	
		execute "reg.ap_cname"& tapnum &".value = reg.ap_cname1_"& tapnum &".value + reg.ap_cname2_"& tapnum &".value"
		execute "reg.ap_ename"& tapnum &".value = reg.ap_ename1_"& tapnum &".value + reg.ap_ename2_"& tapnum &".value"
		if eval("reg.ap_cname1_"&tapnum&".value")<>empty then
			if fDataLen(eval("reg.ap_cname1_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then 
				settab 2
			    execute "reg.ap_cname1_"& tapnum &".focus"
				exit function
			end if
		End IF
		if eval("reg.ap_cname2_"& tapnum &".value")<>empty then
			if fDataLen(eval("reg.ap_cname2_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then
				settab 2
			   execute "reg.ap_cname2_"& tapnum &".focus"
			exit function
			end if
		End IF
		if eval("reg.ap_ename1_"& tapnum &".value")<>empty then
			if fDataLen(eval("reg.ap_ename1_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then
				settab 2
			   execute "reg.ap_ename1_"& tapnum &".focus"
			exit function
			end if
		End IF
		if eval("reg.ap_ename2_"& tapnum &".value")<>empty then
			if fDataLen(eval("reg.ap_ename2_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then 
				settab 2
			   execute "reg.ap_ename2_"& tapnum &".focus"
			exit function	
			end if
		End IF
		if reg.tfy_case_stat.value<>"OO" then	'�s��
		   '2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H
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
	
    //�������e�����ˬd
    if (main.chkCaseForm() == false) return false;


IF reg.tfy_case_stat.value="OO" then
	IF reg.keyseq.value="N" then
		msgbox "�D�ץ�s���ܰʹL�A�Ы�[�T�w]���s�A���s������!!!"
		settab 4
		gname="reg.btnseq_ok.focus"
		execute gname
		exit function
	End IF	
End IF
'�u���v�ӽФ��ˬd
If reg.pfzd_prior_date.value <> empty then
	IF isdate(reg.pfzd_prior_date.value) = false then
		msgbox "���ˬd�u���v�ӽФ�A����榡�O�_���T!!"
		settab 4
		reg.pfzd_prior_date.focus
		exit function
	End If
End If 	

'***�ӽФ��
If reg.tfzd_apply_date.value <> empty then
	IF isdate(reg.tfzd_apply_date.value) = false then
		msgbox "���ˬd�ӽФ�� �A����榡�O�_���T!!"
		settab 4
		reg.tfzd_apply_date.focus
		exit function
	End If
End If 	
'***���U���
If reg.tfzd_issue_date.value <> empty then
	IF isdate(reg.tfzd_issue_date.value) = false then
		msgbox "���ˬd���U��� �A����榡�O�_���T!!"
		settab 4
		reg.tfzd_issue_date.focus
		exit function
	End If
End If 	
'***���i���
If reg.tfzd_open_date.value <> empty then
	IF isdate(reg.tfzd_open_date.value) = false then
		msgbox "���ˬd���i��� �A����榡�O�_���T!!"
		settab 4
		reg.tfzd_open_date.focus
		exit function
	End If
End If
'***���פ��
If reg.tfzd_end_date.value <> empty then
	IF isdate(reg.tfzd_end_date.value) = false then
		msgbox "���ˬd���פ�� �A����榡�O�_���T!!"
		settab 4
		reg.tfzd_end_date.focus
		exit function
	End If
End If
'***�M�δ���
If reg.tfzd_dmt_term1.value <> empty then
	IF isdate(reg.tfzd_dmt_term1.value) = false then
		msgbox "���ˬd�M�δ����_�� �A����榡�O�_���T!!"
		settab 4
		reg.tfzd_dmt_term1.focus
		exit function
	End If
End If 	
'***�M�δ���
If reg.tfzd_dmt_term2.value <> empty then
	IF isdate(reg.tfzd_dmt_term2.value) = false then
		msgbox "���ˬd�M�δ������� �A����榡�O�_���T!!"
		settab 4
		reg.tfzd_dmt_term2.focus
		exit function
	End If
End If 	


	If reg.tfy_case_stat.value="NN" then
		'reg.tfzb_seq.value = reg.New_seq.value
		reg.tfzb_seq1.value = reg.New_seq1.value
	Elseif reg.tfy_case_stat.value="SN" then
		reg.tfzb_seq.value = reg.New_Ass_seq.value
		reg.tfzb_seq1.value = reg.New_Ass_seq1.value
		If reg.New_Ass_seq.value = empty then
		   msgbox "�ץ�s�����o���ťաA�Э��s��J"
		   settab 4
		   reg.New_Ass_seq.focus
		   exit Function
		End if
		If reg.New_Ass_seq1.value = empty then
		   msgbox "�ץ�s���ƽX���o���ťաA�Э��s��J"
		   settab 4
		   reg.New_Ass_seq1.focus
		   exit Function
		End if							
	Elseif	reg.tfy_case_stat.value="OO" then
		reg.tfzb_seq.value = reg.Old_seq.value
		reg.tfzb_seq1.value = reg.Old_seq1.value
		If reg.Old_seq.value = empty then
		   msgbox "��ץ��®׮ɡA�п�J�y�ץ�s���z�Ϋ��U�y�T�w�z�H���o�ԲӸ��!"
		   settab 4
		   reg.Old_seq.focus
		   exit Function
		End if							
	End if
	'�j���׽дڵ��O�ˬd
	if reg.tfzb_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfzb_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!", 64, "Sorry!" 
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
	
'****���w�ϥΰӫ~/�A�����O�ΦW��
'	gname="reg.tfzr_class.value"
'	kname="reg.tfzr_class_count.value"
'	if eval(gname)= empty or eval(kname) = empty then
'		msgbox "�п�J���w�ϥΰӫ~/�A�����O�B�W��!!"
'		settab 4
'		execute "reg.tfzr_class_count.focus"
'		exit function
'	end if
'���O�ˬd
execute "pname=reg.tfzr_class_count.value"	'������w���O�`��
IF eval(pname)<>empty then
	'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
	if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
		for z=1 to eval(pname)
			execute "gname=reg.class1"&z&".value"
			execute "pname=reg.good_name1"&z&".value"
			if pname<>empty and gname=empty  then
				msgbox "�п�J���O!!!"
				settab 4
				execute "reg.class1"&z&".focus"
				exit function
			end if
			if gname<>empty and reg.tfzr_class_type(0).checked then
				if cint(gname) < 0 or cint(gname) > 45 then
					Msgbox "�ϥ����O"&z&"���Ű�ڤ���(001~045)�C"
					settab 4
					execute "reg.class1"&z&".focus"
					exit function
				end if
			end if
		next		
	end if	
End IF	
'���w���O�ˬd
execute "pname=reg.tfzr_class_count.value"	'������w���O�`��
'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
	for z=1 to eval(pname)
		for j=1 to pname
			if z<>j then
				execute "gname=reg.class1"&z&".value"
				execute "kname=reg.class1"&j&".value"
				if gname<>empty  then
					if gname=kname then
					   Msgbox "�ӫ~���O����,�Э��s��J!!!"
					   settab 4
					   execute "reg.class1"&j&".focus"
					   exit function
					end if
				end if
			end if
			execute "kname=reg.class1"&j&".value"
			if kname<>empty and reg.tfzr_class_type(0).checked then
				if cint(kname) < 0 or cint(kname) > 45 then
					Msgbox "�ϥ����O"&j&"���Ű�ڤ���(001~045)�C"
					settab 4
				    execute "reg.class1"&j&".focus"
					exit function
				end if
			end if
		next
	next	
end if	
'***���w���O�ƥ��ˬd
if reg.tfzr_class_count.value<>empty then
	kname="reg.tfzr_class_count.value"
	gname="reg.ctrlcount1.value"
	class_cnt=eval(kname)
	ctrlcnt=eval(gname)
	    if class_cnt <> ctrlcnt then
			answer=msgbox("���w�ϥΰӫ~���O����(�@ "&eval(kname)&" ��)�P��J���w�ϥΰӫ~(�@ "& eval(gname) &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w�ϥΰӫ~�@ "& eval(gname) &" ���H",vbYesNo+vbdefaultbutton2,"�T�{�ӫ~���O����")
			if answer = vbYes then
				execute "reg.tfzr_class_count.value=" & ctrlcnt
			else
				settab 4
				execute "reg.tfzr_class_count.focus"
				exit function
			end if
		end if
end if	

'****�дڵ��O	
if reg.tfzb_seq1.value ="M" then
	reg.tfy_ar_code.value="M"
Elseif reg.nfy_service.value=0 and reg.nfy_fees.value=0 and reg.nfy_oth_money.value=0 and reg.tfy_ar_mark.value="N" then
	reg.tfy_ar_code.value="X"
Else
	reg.tfy_ar_code.value="N"
End IF	


'****�`�p�שʼ�
	if reg.tfy_arcase.value<>empty then
		reg.nfy_tot_case.value=1
	end if
	for q=1 to 5
		qname="reg.nfyi_item_Arcase"&q&".value"
		if eval(qname)<>empty then
			reg.nfy_tot_case.value=reg.nfy_tot_case.value+1
		end if
	next 
	If reg.tfzd_appl_name.value	= empty then
		msgbox "�ӼЦW�٤��o���ťաA�Э��s��J"
		settab 4
		reg.tfzd_appl_name.focus
		exit Function 
	end if	
	IF reg.tfy_case_stat.value<>"OO" then	'�s��
		'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H,�ץ�W��
		if check_CustWatch("appl_name",reg.tfzd_Appl_name.value)=true then 
			settab 4
			reg.tfzd_Appl_name.focus
			exit function  
		end if
	end if

'*****�ץ󤺮e	

if left(reg.tfy_arcase.value,3)="FOB" then
	if trim(reg.tfg1_other_item.value)=empty then
		msgbox "�v�L���e�S���Ŀ�A�п�J!!"
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
		msgbox "�п�J�ӽ��|��ť�Ҥ��ץ����!!"
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
		msgbox "�п�J�ӽФH����!!"
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
		msgbox "�п�J��ӷ�ƤH����!!"
		settab 7
		reg.fr4_tran_mark(0).focus
		exit function
	End IF
	for k=1 to reg.de1_apnum.value   
		IF eval("reg.tfr4_ncname1_" & k & ".value")=empty then
			msgbox "�п�J��ӷ�ƤH�W��!!"
			settab 9
			exit function
		End IF
	next	
	IF reg.fr4_tran_remark1.value=empty then
		msgbox "�п�J���|��ť�Ҥ��z��!!"
		settab 7
		reg.fr4_tran_remark1.focus
		exit function
	End IF
ElseIF left(reg.tfy_arcase.value,3)="AD8" then
	
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "�п�J�ӽ��|��ť�Ҥ��ץ����!!"
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
		msgbox "�п�J�ӽФH����!!"
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
		msgbox "�п�J�s���Ҥγ��z�N����!!"
		settab 7
		reg.fr4_tran_remark1.focus
		exit function
	End IF
End IF
'�ӽаh�O�ˬd
if left(reg.tfy_arcase.value,3)="FOF" then
   if reg.tfzf_other_item.value=empty then
      msgbox "�п�J��w�䲼���Y�W�١I�I"
      settab 8
      reg.tfzf_other_item.focus
      exit function
   end if
   if reg.tfzf_debit_money.value=empty then
      msgbox "�п�J�h�O���B�I�I"
      settab 8
      reg.tfzf_debit_money.focus
      exit function
   else
      if not isnumeric(reg.tfzf_debit_money.value) then
         msgbox "�h�O���B�������ƭȡA�Э��s��J�I�I"
		 settab 8
         reg.tfzf_debit_money.focus
         exit function
      end if
   end if
   if reg.tfzf_other_item1.value=empty then
      msgbox "�п�J�W�O���ڸ��X�I�I"
      settab 8
      reg.tfzf_other_item1.focus
      exit function
   end if
   if reg.tfzf_other_item2.value=empty then
	  <%if not((HTProgRight AND 256) <> 0) then%>'20190613�W�[ �v��C�i����J�h�O��r��
      msgbox "�п�J�����q���h�O��r���I�I"
      settab 8
      reg.ttzf_f1(0).focus
      exit function
	  <%end if%>
   else
      if reg.ttzf_f1(0).checked then
         if reg.f1_yy.value=empty or reg.f1_word.value=empty or reg.f1_no.value=empty then
            msgbox "�п�J�����q���h�O��r���I�I"
			settab 8
			reg.f1_yy.focus
			exit function
		 end if 	
      end if   
      if reg.ttzf_f1(1).checked then
         if reg.f2_yy.value=empty or reg.f2_word.value=empty or reg.f2_no.value=empty then
            msgbox "�п�J�����q���h�O��r���I�I"
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
'�ӽиɰe����ˬd
if left(reg.tfy_arcase.value,3)="FB7" then
	
   if reg.tfb7_other_item.value=empty then
      msgbox "�ФĿ�ɰe���I"
      exit function
   end if
end if
'�ӽкM�^�ӽ��ˬd
if left(reg.tfy_arcase.value,3)="FW1" then
   if reg.tfw1_mod_claim1.checked=false then
      msgbox "�ФĿ�u���ӽЮצ۽кM�^�v"
      exit function
   end if
end if
main.chkEndBack()
'***end***
	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false
    reg.submitTask.value = "ADD"
	if reg.tfzb_seq.value = "" then
	   reg.tfg1_seq.value = "null"
	else
	   reg.tfg1_seq.value = reg.tfzb_seq.value
	end if   
	reg.tfg1_seq1.value= reg.tfzb_seq1.value	
	v=split(reg.tfy_Arcase.value,"&")
	if ubound(v)=2 then
	   pagt_no=v(2)
	else
	   'pagt_no="A05"
	   'pagt_no="A07"	'2008/12/16�]��98�~�ץX�W�N�z�H�קאּA07��&��&�L
	   'pagt_no="A09"	'2013/7/17�]��102�~�ץX�W�N�z�H�קאּA09��&��
	   pagt_no=get_tagtno("N")	'2015/10/21�]��104�~�ץX�W�N�z�H�ק�ç���cust_code.code_type=Tagt_no and mark=N�w�]�X�W�N�z�H
	end if  
	if left(reg.tfy_arcase.value,3)="FOB" then
	    '�X�W�N�z�H�ˬd
		apclass_flag="N"
		for capnum=1 to reg.apnum.value
			IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
				apclass_flag="C"	
			End IF
		next
		if apclass_flag="C" then
	 	      if check_agtno("C",reg.tfg2_agt_no1.value)=true then
	 		     settab 6
	 		 	 reg.tfg2_agt_no1.focus
	 		  	 exit function
	 		  end if
	 	else	  
	 	   if trim(reg.tfg2_agt_no1.value)<>trim(pagt_no) then
	 	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 	       if ans=vbNo then
	 	          settab 6
	 	          reg.tfg2_agt_no1.focus
	 	          exit function
	 	       end if
	 	   end if   
	 	end if
		reg.tfzd_agt_no.value=reg.tfg2_agt_no1.value
	elseIF left(reg.tfy_arcase.value,3)="AD7" or left(reg.tfy_arcase.value,3)="AD8" then
		'�X�W�N�z�H�ˬd
		apclass_flag="N"
		for capnum=1 to reg.apnum.value
			IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
				apclass_flag="C"	
			End IF
		next
		if apclass_flag="C" then
	 	      if check_agtno("C",reg.tfp4_agt_no.value)=true then
	 		     settab 7
	 		 	 reg.tfp4_agt_no.focus
	 		  	 exit function
	 		  end if
	 	else	  
	 	   if trim(reg.tfp4_agt_no.value)<>trim(pagt_no) then
	 	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 	       if ans=vbNo then
	 	          settab 7
	 	          reg.tfp4_agt_no.focus
	 	          exit function
	 	       end if
	 	   end if   
	 	end if
		reg.tfzd_agt_no.value=reg.tfp4_agt_no.value
	elseIF left(reg.tfy_arcase.value,3)="FOF" then
		'�X�W�N�z�H�ˬd
		apclass_flag="N"
		for capnum=1 to reg.apnum.value
			IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
				apclass_flag="C"	
			End IF
		next
		if apclass_flag="C" then
	 	      if check_agtno("C",reg.tfzf_agt_no1.value)=true then
	 		     settab 8
	 		 	 reg.tfzf_agt_no1.focus
	 		  	 exit function
	 		  end if
	 	else	  
	 	   if trim(reg.tfzf_agt_no1.value)<>trim(pagt_no) then
	 	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 	       if ans=vbNo then
	 	          settab 8
	 	          reg.tfzf_agt_no1.focus
	 	          exit function
	 	       end if
	 	   end if   
	 	end if
		reg.tfzd_agt_no.value=reg.tfzf_agt_no1.value	
	elseIF left(reg.tfy_arcase.value,3)="FB7" then
		'�X�W�N�z�H�ˬd
		apclass_flag="N"
		for capnum=1 to reg.apnum.value
			IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
				apclass_flag="C"	
			End IF
		next
		if apclass_flag="C" then
	 	      if check_agtno("C",reg.tfb7_agt_no1.value)=true then
	 		     settab 9
	 		 	 reg.tfb7_agt_no1.focus
	 		  	 exit function
	 		  end if
	 	else	  
	 	   if trim(reg.tfb7_agt_no1.value)<>trim(pagt_no) then
	 	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 	       if ans=vbNo then
	 	          settab 9
	 	          reg.tfb7_agt_no1.focus
	 	          exit function
	 	       end if
	 	   end if   
	 	end if
		reg.tfzd_agt_no.value=reg.tfb7_agt_no1.value		
	Else
		'�X�W�N�z�H�ˬd
		apclass_flag="N"
		for capnum=1 to reg.apnum.value
			IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
				apclass_flag="C"	
			End IF
		next
		if apclass_flag="C" then
	 	      if check_agtno("C",reg.tfg1_agt_no1.value)=true then
	 		     settab 5
	 		 	 reg.tfg1_agt_no1.focus
	 		  	 exit function
	 		  end if
	 	else	  
	 	   if trim(reg.tfg1_agt_no1.value)<>trim(pagt_no) then
	 	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 	       if ans=vbNo then
	 	          settab 5
	 	          reg.tfg1_agt_no1.focus
	 	          exit function
	 	       end if
	 	   end if   
	 	end if
		reg.tfzd_agt_no.value=reg.tfg1_agt_no1.value
	end if
	

'****��L���O�зǮɡA��ȲM��
	if reg.anfees.value = "N" then 
	   reg.nfy_Discount.value =""
	   reg.tfy_discount_remark.value=""	'2016/5/30�W�[�馩�z�� 
	end if   
	reg.action="Brt11AddZZ.asp"	
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
