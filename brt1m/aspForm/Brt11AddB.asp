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
'�שʹw�]�N�z�H2008/1/9
v=split(reg.tfy_Arcase.value,"&")
if ubound(v)=2 then
   pagt_no=v(2)
else
   'pagt_no="A05"
   'pagt_no="A07"	'2008/12/16�]��98�~�ץX�W�N�z�H�קאּA07��&��&�L
   'pagt_no="A09"	'2013/7/17�]��102�~�ץX�W�N�z�H�קאּA09��&��
   pagt_no=get_tagtno("N")	'2015/10/21�]��104�~�ץX�W�N�z�H�ק�ç���cust_code.code_type=Tagt_no and mark=N�w�]�X�W�N�z�H
end if  
'****�Ƶ����
select case left(reg.tfy_arcase.value,3)
case "DR1"
	IF reg.fr1_Appl_name.value=empty then
		msgbox "�ӼЦW�٤��i�ťաI�I"
		settab 6
		reg.fr1_Appl_name.focus
		exit function
	End IF
	'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H,�ץ�W��
	if check_CustWatch("appl_name",reg.fr1_Appl_name.value)=true then 
		settab 6
		reg.fr1_Appl_name.focus
		exit function  
	end if
	'2013/12/12�ƻs�U�@���A�ץ�W�٤ε��U���A�p���ק�N�s�ɡA��ƪťաA�ҥH�A���@����
	reg.tfzd_appl_name.value=reg.fr1_appl_name.value
	reg.tfzd_issue_no.value=reg.fr1_issue_no.value
	if reg.tfp1_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfp1_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!", 64, "Sorry!" 
		settab 6
		reg.tfp1_seq1.focus 
		Exit function
	end if
	'IF reg.tfy_ar_mark.value = "X" then 
	'	MsgBox "�дڵ��O���o���j���i�f�� !!", 64, "Sorry!" 
	'	settab 3
	'	reg.tfy_ar_mark.focus 
	'	Exit function
	'end if
	If reg.R_O_item1.value <> empty then
		IF isdate(reg.R_O_item1.value) = false then
			msgbox "���ˬd�����p�ץ��� �A����榡�O�_���T!!"
			settab 6
			reg.R_O_item1.focus
			exit function
		End If
	End If 	
	IF reg.R_O_item1.value<>empty or reg.R_O_item2.value<>empty or reg.R_O_item3.value<>empty then
		reg.tfz1_other_item.value=reg.R_O_item1.value&";"&reg.R_O_item2.value&";"&reg.R_O_item3.value
	End IF
	if trim(reg.ttg11_mod_pul_new_no.value) <> empty or trim(reg.ttg11_mod_pul_ncname1.value)<>empty  then
		if reg.ttg11_mod_pul_mod_type(0).checked=false and reg.ttg11_mod_pul_mod_type(1).checked=false then
			msgbox "��"&reg.ttg11_mod_pul_new_no.value&"���u"&reg.ttg11_mod_pul_ncname1.value&"�v����J��ơA�п�ܰӼЩμг��A�p����ܡA�бN��J��ƲM�šI"
			settab 6
			reg.ttg11_mod_pul_mod_type(0).focus
			exit function
		End IF
	End IF
	if trim(reg.ttg13_mod_pul_new_no.value) <> empty or trim(reg.ttg13_mod_pul_mod_dclass.value) <> empty then
		if reg.ttg13_mod_pul_mod_type.checked=false then
			msgbox "���w�ϥΩ�ӼЪk�I��ӫh��"&reg.ttg13_mod_pul_new_no.value&"����"&reg.ttg13_mod_pul_mod_dclass.value&"���ӫ~���A�Ȥ����U�����o���J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI"
			settab 6
			reg.ttg13_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	if trim(reg.ttg14_mod_pul_new_no.value) <> empty or trim(reg.ttg14_mod_pul_mod_dclass.value) <> empty or trim(reg.ttg14_mod_pul_ncname1.value)<>empty  then
		if reg.ttg14_mod_pul_mod_type.checked=false then
			msgbox "���w�ϥΩ�ӼЪk�I��ӫh��"&reg.ttg14_mod_pul_new_no.value&"����"&reg.ttg14_mod_pul_mod_dclass.value&"��"&reg.ttg14_mod_pul_ncname1.value&"�ӫ~���A�Ȥ��Ӽ��v�����o���J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI"
			settab 6
			reg.ttg14_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	'�X�W�N�z�H�ˬd
	apclass_flag="N"
	for capnum=1 to reg.apnum.value
		IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
			apclass_flag="C"	
		End IF
	next
	if apclass_flag="C" then
	      if check_agtno("C",reg.tfp1_agt_no.value)=true then
		     settab 6
		 	 reg.tfp1_agt_no.focus
		  	 exit function
		  end if
	else	  
	   if trim(reg.tfp1_agt_no.value)<>trim(pagt_no) then
	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	       if ans=vbNo then
	          settab 6
	          reg.tfp1_agt_no.focus
	          exit function
	       end if
	   end if   
	end if
	
	'2012/10/3�W�[�o��ӼХ]�t�����A�]2012/7/1�s�ӽЮѭק�
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
	reg.tfzd_agt_no.value=reg.tfp1_agt_no.value
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
		   msgbox "�ץ�s�����o���ťաA�Э��s��J"
		   settab 6
		   reg.tfp1_New_Ass_seq.focus
		   exit Function
		End if
		If reg.tfp1_New_Ass_seq1.value = empty then
		   msgbox "�ץ�s���ƽX���o���ťաA�Э��s��J"
		   settab 6
		   reg.tfp1_New_Ass_seq1.focus
		   exit Function
		End if
	end if
	
case "DO1"
	IF reg.fr2_Appl_name.value=empty then
		msgbox "�ӼЦW�٤��i�ťաI�I"
		settab 5
		reg.fr2_Appl_name.focus
		exit function
	End IF
	'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H,�ץ�W��
	if check_CustWatch("appl_name",reg.fr2_Appl_name.value)=true then 
		settab 5
		reg.fr2_Appl_name.focus
		exit function  
	end if
	'2013/12/12�ƻs�U�@���A�ץ�W�٤ε��U���A�p���ק�N�s�ɡA��ƪťաA�ҥH�A���@����
	reg.tfzd_appl_name.value=reg.fr2_appl_name.value
	reg.tfzd_issue_no.value=reg.fr2_issue_no.value
	if reg.tfp2_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfp2_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!", 64, "Sorry!" 
		settab 5
		reg.tfp2_seq1.focus 
		Exit function
	end if
	'IF reg.tfy_ar_mark.value = "X" then 
	'	MsgBox "�дڵ��O���o���j���i�f�� !!", 64, "Sorry!" 
	'	settab 3
	'	reg.tfy_ar_mark.focus 
	'	Exit function
	'end if
	If reg.O_O_item1.value <> empty then
		IF isdate(reg.O_O_item1.value) = false then
			msgbox "���ˬd�����p�ץ��� �A����榡�O�_���T!!"
			settab 5
			reg.O_O_item1.focus
			exit function
		End If
	End If 	
	IF reg.O_O_item1.value<>empty or reg.O_O_item2.value<>empty or reg.O_O_item3.value<>empty then
		reg.tfz2_other_item.value=reg.O_O_item1.value&";"&reg.O_O_item2.value&";"&reg.O_O_item3.value
	End IF
	if trim(reg.ttg21_mod_pul_new_no.value) <> empty or trim(reg.ttg21_mod_pul_ncname1.value)<>empty  then
		if reg.ttg21_mod_pul_mod_type(0).checked=false and reg.ttg21_mod_pul_mod_type(1).checked=false then
			msgbox "��"&reg.ttg21_mod_pul_new_no.value&"���u"&reg.ttg21_mod_pul_ncname1.value&"���v����J��ơA�п�ܰӼЩμг��A�p����ܡA�бN��J��ƲM�šI"
			settab 5
			reg.ttg21_mod_pul_mod_type(0).focus
			exit function
		End IF
	End IF
	if trim(reg.ttg23_mod_pul_new_no.value) <> empty or trim(reg.ttg23_mod_pul_mod_dclass.value) <> empty then
		if reg.ttg23_mod_pul_mod_type.checked=false then
			msgbox "���w�ϥΩ�ӼЪk�I��ӫh��"&reg.ttg23_mod_pul_new_no.value&"����"&reg.ttg23_mod_pul_mod_dclass.value&"���ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI"
			settab 5
			reg.ttg23_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	if trim(reg.ttg24_mod_pul_new_no.value) <> empty or trim(reg.ttg24_mod_pul_mod_dclass.value) <> empty or trim(reg.ttg24_mod_pul_ncname1.value)<>empty  then
		if reg.ttg24_mod_pul_mod_type.checked=false then
			msgbox "���w�ϥΩ�ӼЪk�I��ӫh��"&reg.ttg24_mod_pul_new_no.value&"����"&reg.ttg24_mod_pul_mod_dclass.value&"��"&reg.ttg24_mod_pul_ncname1.value&"�ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI"
			settab 5
			reg.ttg24_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	'�X�W�N�z�H�ˬd
	apclass_flag="N"
	for capnum=1 to reg.apnum.value
		IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
			apclass_flag="C"	
		End IF
	next
	if apclass_flag="C" then
	      if check_agtno("C",reg.tfp2_agt_no.value)=true then
		     settab 5
		 	 reg.tfp2_agt_no.focus
		  	 exit function
		  end if
	else	  
	   if trim(reg.tfp2_agt_no.value)<>trim(pagt_no) then
	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	       if ans=vbNo then
	          settab 5
	          reg.tfp2_agt_no.focus
	          exit function
	       end if
	   end if   
	end if
	
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
	reg.tfzd_agt_no.value=reg.tfp2_agt_no.value		
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
		   msgbox "�ץ�s�����o���ťաA�Э��s��J"
		   settab 5
		   reg.tfp2_New_Ass_seq.focus
		   exit Function
		End if
		If reg.tfp2_New_Ass_seq1.value = empty then
		   msgbox "�ץ�s���ƽX���o���ťաA�Э��s��J"
		   settab 5
		   reg.tfp2_New_Ass_seq1.focus
		   exit Function
		End if
	end if			

	'IF reg.D_remark2.value<>empty then
	'	if reg.O_cappl_name.checked=false and reg.O_eappl_name.checked=false and reg.O_jappl_name.checked=false and reg.O_draw.checked=false and reg.O_zappl_name.checked=false then
	'		msgbox "�ФĿ�Ӽ�/�г��ϼ˨��@�����H�k!!"
	'		settab 5
	'		reg.O_cappl_name.focus
	'		exit function
	'	End IF
	'End iF
case "DI1"
	IF reg.fr3_Appl_name.value=empty then
		msgbox "�ӼЦW�٤��i�ťաI�I"
		settab 7
		reg.fr3_Appl_name.focus
		exit function
	End IF
	IF reg.fr3_Appl_name.value=empty then
		msgbox "�ӼЦW�٤��i�ťաI�I"
		settab 7
		reg.fr3_Appl_name.focus
		exit function
	End IF
	'2013/12/12�ƻs�U�@���A�ץ�W�٤ε��U���A�p���ק�N�s�ɡA��ƪťաA�ҥH�A���@����
	reg.tfzd_appl_name.value=reg.fr3_appl_name.value
	reg.tfzd_issue_no.value=reg.fr3_issue_no.value
	if reg.tfp3_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!", 64, "Sorry!" 
		settab 3
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfp3_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!", 64, "Sorry!" 
		settab 7
		reg.tfp3_seq1.focus 
		Exit function
	end if
	'IF reg.tfy_ar_mark.value = "X" then 
	'	MsgBox "�дڵ��O���o���j���i�f�� !!", 64, "Sorry!" 
	'	settab 3
	'	reg.tfy_ar_mark.focus 
	'	Exit function
	'end if
	If reg.I_O_item1.value <> empty then
		IF isdate(reg.I_O_item1.value) = false then
			msgbox "���ˬd�����p�ץ��� �A����榡�O�_���T!!"
			settab 7
			reg.I_O_item1.focus
			exit function
		End If
	End If
	IF reg.I_O_item1.value<>empty or reg.I_O_item2.value<>empty or reg.I_O_item3.value<>empty then
		reg.tfz3_other_item.value=reg.I_O_item1.value&";"&reg.I_O_item2.value&";"&reg.I_O_item3.value
	End IF
	if trim(reg.ttg31_mod_pul_new_no.value) <> empty or trim(reg.ttg31_mod_pul_ncname1.value)<>empty  then
		if reg.ttg31_mod_pul_mod_type(0).checked=false and reg.ttg31_mod_pul_mod_type(1).checked=false then
			msgbox "��"&reg.ttg31_mod_pul_new_no.value&"���u"&reg.ttg31_mod_pul_ncname1.value&"���v����J��ơA�п�ܰӼЩμг��A�p����ܡA�бN��J��ƲM�šI"
			settab 7
			reg.ttg31_mod_pul_mod_type(0).focus
			exit function
		End IF
	End IF
	if trim(reg.ttg33_mod_pul_new_no.value) <> empty or trim(reg.ttg33_mod_pul_mod_dclass.value) <> empty then
		if reg.ttg33_mod_pul_mod_type.checked=false then
			msgbox "���w�ϥΩ�ӼЪk�I��ӫh��"&reg.ttg33_mod_pul_new_no.value&"����"&reg.ttg33_mod_pul_mod_dclass.value&"���ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI"
			settab 7
			reg.ttg33_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	if trim(reg.ttg34_mod_pul_new_no.value) <> empty or trim(reg.ttg34_mod_pul_mod_dclass.value) <> empty or trim(reg.ttg34_mod_pul_ncname1.value)<>empty  then
		if reg.ttg34_mod_pul_mod_type.checked=false then
			msgbox "���w�ϥΩ�ӼЪk�I��ӫh��"&reg.ttg34_mod_pul_new_no.value&"����"&reg.ttg34_mod_pul_mod_dclass.value&"��"&reg.ttg34_mod_pul_ncname1.value&"�ӫ~���A�Ȥ����U�����M�P����J��ơA�ФĿ�A�p���Ŀ�A�бN��J��ƲM�šI"
			settab 7
			reg.ttg34_mod_pul_mod_type.focus
			exit function
		End IF
	End IF
	'�X�W�N�z�H�ˬd
	apclass_flag="N"
	for capnum=1 to reg.apnum.value
		IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
			apclass_flag="C"	
		End IF
	next
	if apclass_flag="C" then
	      if check_agtno("C",reg.tfp3_agt_no.value)=true then
		     settab 7
		 	 reg.tfp3_agt_no.focus
		  	 exit function
		  end if
	else	  
	   if trim(reg.tfp3_agt_no.value)<>trim(pagt_no) then
	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	       if ans=vbNo then
	          settab 7
	          reg.tfp3_agt_no.focus
	          exit function
	       end if
	   end if   
	end if
	
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
		'2013/1/24�]���ӼЪk�ץ��אּ�h��
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
	reg.tfzd_agt_no.value=reg.tfp3_agt_no.value		
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
		   msgbox "�ץ�s�����o���ťաA�Э��s��J"
		   settab 7
		   reg.tfp3_New_Ass_seq.focus
		   exit Function
		End if
		If reg.tfp3_New_Ass_seq1.value = empty then
		   msgbox "�ץ�s���ƽX���o���ťաA�Э��s��J"
		   settab 7
		   reg.tfp3_New_Ass_seq1.focus
		   exit Function
		End if
	end if
case else
	IF reg.tfy_case_stat.value="NN" or reg.tfy_case_stat.value="SN" then
		IF reg.tfzd_Appl_name.value=empty then
			msgbox "�ӼЦW�٤��i�ťաI�I"
			settab 4
			reg.tfzd_Appl_name.focus
			exit function
		End IF
		'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H,�ץ�W��
		if check_CustWatch("appl_name",reg.tfzd_Appl_name.value)=true then 
			settab 4
			reg.tfzd_Appl_name.focus
			exit function  
		end if
	End IF		
	IF reg.tfy_case_stat.value="OO" then
		IF reg.keyseq.value="N" then
			msgbox "�D�ץ�s���ܰʹL�A�Ы�[�T�w]���s�A���s������!!!"
			settab 4
			gname="reg.btnseq_ok.focus"
			execute gname
			exit function
		End IF	
	End IF		
	If reg.tfy_case_stat.value="NN" then
		'reg.tfzb_seq.value = "null"
		reg.tfzb_seq.value = reg.New_seq.value
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
	'�X�W�N�z�H�ˬd
	if left(reg.tfy_arcase.value,3)<>"DE1" and left(reg.tfy_arcase.value,3)<>"DE2" then
		apclass_flag="N"
		for capnum=1 to reg.apnum.value
			IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
				apclass_flag="C"	
			End IF
		next
		if apclass_flag="C" then
		      if check_agtno("C",reg.tfg1_agt_no1.value)=true then
			     settab 8
			 	 reg.tfg1_agt_no1.focus
			  	 exit function
			  end if
		else	  
		   if trim(reg.tfg1_agt_no1.value)<>trim(pagt_no) then
		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
		       if ans=vbNo then
		          settab 8
		          reg.tfg1_agt_no1.focus
		          exit function
		       end if
		   end if   
		end if
	end if	
	reg.tfzd_agt_no.value=reg.tfg1_agt_no1.value
End Select
'�ץ󤺮e
IF left(reg.tfy_arcase.value,3)="DE1" then
	
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "�п�J�ӽ��|��ť�Ҥ��ץ����!!"
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
		msgbox "�п�J�ӽФH����!!"
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
		msgbox "�п�J��ӷ�ƤH����!!"
		settab 9
		reg.fr4_tran_mark(0).focus
		exit function
	End IF
	if reg.de1_apnum.value = 0 then
	   msgbox "�п�J��ӷ�ƤH��ơI"
	   settab 9
	   exit function
	end if
	for k=1 to reg.de1_apnum.value   
		IF eval("reg.tfr4_ncname1_" & k & ".value")=empty then
			msgbox "�п�J��ӷ�ƤH�W��!!"
			settab 9
			exit function
		End IF
	next	
	IF reg.fr4_tran_remark1.value=empty then
		msgbox "�п�J���|��ť�Ҥ��z��!!"
		settab 9
		reg.fr4_tran_remark1.focus
		exit function
	End IF
	'�X�W�N�z�H�ˬd
	apclass_flag="N"
	for capnum=1 to reg.apnum.value
		IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
			apclass_flag="C"	
		End IF
	next
	if apclass_flag="C" then
	      if check_agtno("C",reg.tfp4_agt_no.value)=true then
		     settab 9
		 	 reg.tfp4_agt_no.focus
		  	 exit function
		  end if
	else	  
	   if trim(reg.tfp4_agt_no.value)<>trim(pagt_no) then
	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	       if ans=vbNo then
	          settab 9
	          reg.tfp4_agt_no.focus
	          exit function
	       end if
	   end if   
	end if
	reg.tfzd_agt_no.value=reg.tfp4_agt_no.value
ElseIF left(reg.tfy_arcase.value,3)="DE2" then
	
	IF reg.fr4_remark3(0).checked=false and reg.fr4_remark3(1).checked=false and reg.fr4_remark3(2).checked=false then
		msgbox "�п�J�ӽ��|��ť�Ҥ��ץ����!!"
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
		msgbox "�п�J�ӽФH����!!"
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
		msgbox "�п�J�s���Ҥγ��z�N����!!"
		settab 9
		reg.fr4_tran_remark1.focus
		exit function
	End IF
	'�X�W�N�z�H�ˬd
	apclass_flag="N"
	for capnum=1 to reg.apnum.value
		IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
			apclass_flag="C"	
		End IF
	next
	if apclass_flag="C" then
	      if check_agtno("C",reg.tfp4_agt_no.value)=true then
		     settab 9
		 	 reg.tfp4_agt_no.focus
		  	 exit function
		  end if
	else	  
	   if trim(reg.tfp4_agt_no.value)<>trim(pagt_no) then
	       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	       if ans=vbNo then
	          settab 9
	          reg.tfp4_agt_no.focus
	          exit function
	       end if
	   end if   
	end if
	reg.tfzd_agt_no.value=reg.tfp4_agt_no.value
End IF
'***end***
main.chkEndBack()
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

'2010/10/4��ĳ�B���w�μo��W�[�O�����O�A�����ˬd���O�Ψ�ӫ~��ơA�����ˬd���O�ƻP��J�O�����ƬO�_�ۦP
IF left(reg.tfy_arcase.value,3)="DO1" or left(reg.tfy_arcase.value,3)="DI1" or left(reg.tfy_arcase.value,3)="DR1" then
	'2010/10/8���O�ˬd�A�ܤֿ�J�@��
	parcase=left(reg.tfy_arcase.value,3)
	ptab_num=3	'tab��
	sclass_count=1	'���O�з����O�ơA��ǭ�=1
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
	   msgbox "�п�J���O��ơI"
	   settab ptab_num
	   execute "reg." & pname & ".focus"
	   exit function
	end if
	if cint(pclass_count)<>cint(sclass_count) then
	   msgbox "���O���C���O��(�@" & sclass_count & "��)�P��줺�e���O��(�@" & pclass_count & "��)���P�A���ˬd�I"
	   'settab ptab_num
	   'execute "reg." & pname & ".focus"
	   settab 3
	   exit function
	end if
else	
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
			for j=1 to eval(pname)
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

		reg.F_tscode.disabled = false
		reg.tfzd_tcn_mark.disabled = false
		reg.tfg1_seq.value = reg.tfzb_seq.value
		reg.tfg1_seq1.value= reg.tfzb_seq1.value		
'****��L���O�зǮɡA��ȲM��
	if reg.anfees.value = "N" then 
	   reg.nfy_Discount.value =""
	   reg.tfy_discount_remark.value=""	'2016/5/30�W�[�馩�z��
	end if   
	reg.action="Brt11AddB.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
