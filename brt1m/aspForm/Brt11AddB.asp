<%
function formAddSubmit()	
'----- �Τ��Submit�e���ˬd�X��b�o�� �A�p�U�� not valid �� exit sub ���}------------ 
    //�Ȥ��p���H�ˬd
    if (main.chkCustAtt() == false) return false;
	
    //�ӽФH�ˬd
    if (main.chkApp() == false) return false;
	
	//����榡�ˬd,��class=dateField,����J�h�ˬd
    if (main.chkDate("#case") == false) { alert("����榡���~,���˪H"); return false; }
    if (main.chkDate("#dmt") == false) { alert("����榡���~,���˪H"); return false; }
    if (main.chkDate("#tran") == false) { alert("����榡���~,���˪H"); return false; }

 	//�ӼЦW���ˬd
    if (main.chkApplName() == false) return false;

    //��������ˬd
    if (main.chkRequire() == false) return false;

    //�������e�����ˬd
    if (main.chkCaseForm() == false) return false;

'****�Ƶ����
select case left(reg.tfy_arcase.value,3)
case "DR1"
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

	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum","apclass","tfp1_agt_no") == false) return false;

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

	//�X�W�N�z�H�ˬd
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
case "DI1"
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

	//�X�W�N�z�H�ˬd
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
	if left(reg.tfy_arcase.value,3)<>"DE1" and left(reg.tfy_arcase.value,3)<>"DE2" then
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;
	end if	
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

	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum","apclass","tfp4_agt_no") == false) return false;

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

	//�X�W�N�z�H�ˬd
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
    //�D�ɰӫ~���O�ˬd
    if (main.chkGood() == false) return false;
end if	

    //�ˬd�j���׽дڵ��O�ˬd&����
    if (main.chkAr() == false) return false;

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
   
	reg.action="Brt11AddB.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
