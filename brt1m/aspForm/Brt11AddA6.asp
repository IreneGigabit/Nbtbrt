<%
function formAddSubmit()	
'----- �Τ��Submit�e���ˬd�X��b�o�� �A�p�U�� not valid �� exit sub ���}------------ 
main.chkCustAtt();

	'�ӽФH�ˬd
	Select Case left(reg.tfy_arcase.value,4)
	Case "FC1&","FC10","FC11","FC9&","FC7&","FC5&","FCA&","FCB&","FCF&","FCH&"
		IF reg.apnum.value=0 then
			msgbox "�п�J�ӽФH��ơI�I"
			exit function
		End IF
		for tapnum=1 to reg.apnum.value
			if eval("reg.dbmn1_new_no"& tapnum &".value") = empty then	
				MsgBox "�ӽФH�s�����o���ťաI", 64, "Sorry!"
				settab 4
				execute "reg.dbmn1_new_no"& tapnum &".focus"
				Exit function  
			end if
			execute "reg.dbmn1_ap_cname" & tapnum & ".value = reg.dbmn1_ncname1_" & tapnum & ".value + reg.dbmn1_ncname2_" & tapnum & ".value"	
			execute "reg.dbmn1_ap_ename" & tapnum & ".value = reg.dbmn1_nename1_" & tapnum & ".value + reg.dbmn1_nename2_" & tapnum & ".value"
			if eval("reg.dbmn1_ncname1_"&tapnum&".value")<>empty then
				if fDataLen(eval("reg.dbmn1_ncname1_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then 
					settab 4
				    execute "reg.dbmn1_ncname1_"& tapnum &".focus"
					exit function
				end if
			End IF
			if eval("reg.dbmn1_ncname2_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.dbmn1_ncname2_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then
					settab 4
				   execute "reg.dbmn1_ncname2_"& tapnum &".focus"
				exit function
				end if
			End IF
			if eval("reg.dbmn1_nename1_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.dbmn1_nename1_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then
					settab 4
				   execute "reg.dbmn1_nename1_"& tapnum &".focus"
				exit function
				end if
			End IF
			if eval("reg.dbmn1_nename2_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.dbmn1_nename2_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then 
					settab 4
				   execute "reg.dbmn1_nename2_"& tapnum &".focus"
				exit function	
				end if
			End IF
			if reg.tfy_case_stat.value<>"OO" then	'�s��
				'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H
				if cust_name_chk(eval("reg.dbmn1_ap_cname"& tapnum &".value"),eval("reg.dbmn1_ap_ename"& tapnum &".value"))=true then 
					settab 4
					exit function
				end if   
				if aprep_name_chk(eval("reg.dbmn1_ncrep"& tapnum &".value"),eval("reg.dbmn1_nerep"& tapnum &".value"))=true then 
					settab 4
					exit function
				end if   
			end if
		next	
		
		
		
	Case "FC2&","FC20","FC21","FC0&","FC6&","FC8&","FCC&","FCD&","FCG&","FCI&"
	    '2010/10/5�W�[����ݶ�g�ӽФH�����~��s��
	    if reg.tfzd_mark(0).checked=false and reg.tfzd_mark(1).checked=false and reg.tfzd_mark(2).checked=false and reg.tfzd_mark(3).checked=false then
	       msgbox "�п�ܥӽФH�ܧ�����I"
	       settab 5
	       reg.tfzd_mark(0).focus
	       exit function
	    end if
		IF reg.fc0_apnum.value=0 then
			msgbox "�п�J�ӽФH��ơI�I"
			exit function
		End IF
	    for tapnum=1 to reg.fc0_apnum.value
			if eval("reg.dbmn_new_no"& tapnum &".value") = empty then	
				MsgBox "�ӽФH�s�����o���ťաI", 64, "Sorry!"
				settab 5
				execute "reg.dbmn_new_no"& tapnum &".focus"
				Exit function  
			end if
			execute "reg.dbmn_ap_cname" & tapnum & ".value = reg.dbmn_ncname1_" & tapnum & ".value + reg.dbmn_ncname2_" & tapnum & ".value"	
			execute "reg.dbmn_ap_ename" & tapnum & ".value = reg.dbmn_nename1_" & tapnum & ".value + reg.dbmn_nename2_" & tapnum & ".value"
			if eval("reg.dbmn_ncname1_"&tapnum&".value")<>empty then
				if fDataLen(eval("reg.dbmn_ncname1_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then 
					settab 5
				    execute "reg.dbmn_ncname1_"& tapnum &".focus"
					exit function
				end if
			End IF
			if eval("reg.dbmn_ncname2_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.dbmn_ncname2_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then
					settab 5
				   execute "reg.dbmn_ncname2_"& tapnum &".focus"
				exit function
				end if
			End IF
			if eval("reg.dbmn_nename1_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.dbmn_nename1_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then
					settab 5
				   execute "reg.dbmn_nename1_"& tapnum &".focus"
				exit function
				end if
			End IF
			if eval("reg.dbmn_nename2_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.dbmn_nename2_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then 
					settab 5
				   execute "reg.dbmn_nename2_"& tapnum &".focus"
				exit function	
				end if
			End IF
			if reg.tfy_case_stat.value<>"OO" then	'�s��
				'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H
				if cust_name_chk(eval("reg.dbmn_ap_cname"& tapnum &".value"),eval("reg.dbmn_ap_ename"& tapnum &".value"))=true then 
					settab 5
					exit function
				end if   
				if aprep_name_chk(eval("reg.dbmn_ncrep"& tapnum &".value"),eval("reg.dbmn_nerep"& tapnum &".value"))=true then 
					settab 5
					exit function
				end if   
			end if
		next	
		
	Case "FC3&","FC4&"
		IF reg.fc_apnum.value=0 then
			msgbox "�п�J�ӽФH��ơI�I"
			exit function
		End IF
	    for tapnum=1 to reg.fc_apnum.value
			if eval("reg.apcust_no"& tapnum &".value") = empty then	
				MsgBox "�ӽФH�s�����o���ťաI", 64, "Sorry!"
				settab 5
				execute "reg.apcust_no"& tapnum &".focus"
				Exit function  
			end if
			execute "reg.ap_cname" & tapnum & ".value = reg.ap_cname1_" & tapnum & ".value + reg.ap_cname2_" & tapnum & ".value"	
			execute "reg.ap_ename" & tapnum & ".value = reg.ap_ename1_" & tapnum & ".value + reg.ap_ename2_" & tapnum & ".value"
			if eval("reg.ap_cname1_"&tapnum&".value")<>empty then
				if fDataLen(eval("reg.ap_cname1_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then 
					settab 6
				    execute "reg.ap_cname1_"& tapnum &".focus"
					exit function
				end if
			End IF
			if eval("reg.ap_cname2_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.ap_cname2_"& tapnum &".value"),44,"�ӽФH�W��(��)")="" then
					settab 6
				   execute "reg.ap_cname2_"& tapnum &".focus"
					exit function
				end if
			End IF
			if eval("reg.ap_ename1_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.ap_ename1_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then
					settab 6
				   execute "reg.ap_ename1_"& tapnum &".focus"
					exit function
				end if
			End IF
			if eval("reg.ap_ename2_"& tapnum &".value")<>empty then
				if fDataLen(eval("reg.ap_ename2_"& tapnum &".value"),100,"�ӽФH�W��(�^)")="" then 
					settab 6
				   execute "reg.ap_ename2_"& tapnum &".focus"
				   exit function	
				end if
			End IF
			if reg.tfy_case_stat.value<>"OO" then	'�s��
				'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H
				if cust_name_chk(eval("reg.ap_cname"& tapnum &".value"),eval("reg.ap_ename"& tapnum &".value"))=true then 
					settab 6
					exit function
				end if   
				if aprep_name_chk(eval("reg.ap_crep"& tapnum &".value"),eval("reg.ap_crep"& tapnum &".value"))=true then 
					settab 6
					exit function
				end if   
			end if
		next	
		
		
	End Select
	
	if left(reg.tfy_arcase.value,3) = "FC1" or left(reg.tfy_arcase.value,3) = "FC9" or left(reg.tfy_arcase.value,3) = "FC5" or left(reg.tfy_arcase.value,3) = "FC7" or left(reg.tfy_arcase.value,3) = "FCA" or left(reg.tfy_arcase.value,3) = "FCB" or left(reg.tfy_arcase.value,3) = "FCF" or left(reg.tfy_arcase.value,3) = "FCH"  then
		'alert reg.dbmo1_old_no.value
		for k=1 to reg.FC1_apnum.value
			if eval("reg.dbmo1_old_no" & k & ".value")<>empty then
				execute "reg.tft1_old_no" & k & ".value = reg.dbmo1_old_no" & k & ".value"
			end if
			if eval("reg.dbmo1_ocname1_" & k & ".value")<> empty then
				execute "reg.tft1_ocname1_" & k & ".value=reg.dbmo1_ocname1_" & k & ".value"
			end if
			if eval("reg.dbmo1_ocname2_" & k & ".value")<> empty then
				execute "reg.tft1_ocname2_" & k & ".value=reg.dbmo1_ocname2_" & k & ".value"
			end if
			if eval("reg.dbmo1_oename1_" & k & ".value")<> empty then
				execute "reg.tft1_oename1_" & k & ".value=reg.dbmo1_oename1_" & k & ".value"
			end if
			if eval("reg.dbmo1_oename2_" & k & ".value")<> empty then
				execute "reg.tft1_oename2_" & k & ".value=reg.dbmo1_oename2_" & k & ".value"
			end if
		next	
	End if	
	
    //�������e�����ˬd
    if (main.chkCaseForm() == false) return false;


'�u���v�ӽФ��ˬd
If reg.pfzd_prior_date.value <> empty then
	IF isdate(reg.pfzd_prior_date.value) = false then
		msgbox "���ˬd�u���v�ӽФ�A����榡�O�_���T!!"
		settab 3
		reg.pfzd_prior_date.focus
		exit function
	End If
End If 	
IF reg.tfy_case_stat.value=empty then
	msgbox "�п�J�ץ����!!"
	settab 3
	reg.tfy_case_stat.focus
	exit function
End IF
IF reg.tfy_case_stat.value="NN" or reg.tfy_case_stat.value="SN" then
	IF reg.tfzd_Appl_name.value=empty then
		msgbox "�ӼЦW�٤��i�ťաI�I"
		settab 3
		reg.tfzd_Appl_name.focus
		exit function
	End IF
	'2014/4/22�W�[�ˬd�O�_������N�z�d�ӹ�H,�ץ�W��
    if check_CustWatch("appl_name",reg.tfzd_Appl_name.value)=true then 
        settab 3
	    reg.tfzd_Appl_name.focus
        exit function  
    end if
End IF
IF reg.tfy_case_stat.value="OO" then
	IF reg.keyseq.value="N" then
		msgbox "�D�ץ�s���ܰʹL�A�Ы�[�T�w]���s�A���s������!!!"
		settab 3
		gname="reg.btnseq_ok.focus"
		execute gname
		exit function
	End IF	
End IF
'***�ӽФ��
If reg.tfzd_apply_date.value <> empty then
	IF isdate(reg.tfzd_apply_date.value) = false then
		msgbox "���ˬd�ӽФ�� �A����榡�O�_���T!!"
		settab 3
		reg.tfzd_apply_date.focus
		exit function
	End If
End If 	
'***���U���
If reg.tfzd_issue_date.value <> empty then
	IF isdate(reg.tfzd_issue_date.value) = false then
		msgbox "���ˬd���U��� �A����榡�O�_���T!!"
		settab 3
		reg.tfzd_issue_date.focus
		exit function
	End If
End If 	
'***���i���
If reg.tfzd_open_date.value <> empty then
	IF isdate(reg.tfzd_open_date.value) = false then
		msgbox "���ˬd���i��� �A����榡�O�_���T!!"
		settab 3
		reg.tfzd_open_date.focus
		exit function
	End If
End If
'***���פ��
If reg.tfzd_end_date.value <> empty then
	IF isdate(reg.tfzd_end_date.value) = false then
		msgbox "���ˬd���פ�� �A����榡�O�_���T!!"
		settab 3
		reg.tfzd_end_date.focus
		exit function
	End If
End If
'***�M�δ���
If reg.tfzd_dmt_term1.value <> empty then
	IF isdate(reg.tfzd_dmt_term1.value) = false then
		msgbox "���ˬd�M�δ����_�� �A����榡�O�_���T!!"
		settab 3
		reg.tfzd_dmt_term1.focus
		exit function
	End If
End If 	
'***�M�δ���
If reg.tfzd_dmt_term2.value <> empty then
	IF isdate(reg.tfzd_dmt_term2.value) = false then
		msgbox "���ˬd�M�δ������� �A����榡�O�_���T!!"
		settab 3
		reg.tfzd_dmt_term2.focus
		exit function
	End If
End If 	
'****�Ƶ����FC2
If reg.O_item21.value <> empty then
	IF isdate(reg.O_item21.value) = false then
		msgbox "���ˬd�Ƶ���� �A����榡�O�_���T!!"
		settab 9
		reg.O_item21.focus
		exit function
	End If
End If 	
'****�Ƶ����FC21
If reg.O_item211.value <> empty then
	IF isdate(reg.O_item211.value) = false then
		msgbox "���ˬd�Ƶ���� �A����榡�O�_���T!!"
		settab 10
		reg.O_item211.focus
		exit function
	End If
End If 	
'****�Ƶ����FC3
If reg.O_item31.value <> empty then
	IF isdate(reg.O_item31.value) = false then
		msgbox "���ˬd�Ƶ���� �A����榡�O�_���T!!"
		settab 11
		reg.O_item31.focus
		exit function
	End If
End If 	

if left(reg.tfy_arcase.value,3)="FC2" or left(reg.tfy_arcase.value,3)="FC0" or left(reg.tfy_arcase.value,3)="FC6" or left(reg.tfy_arcase.value,3)="FC8" _
or left(reg.tfy_arcase.value,3)="FCC" or left(reg.tfy_arcase.value,3)="FCD" or left(reg.tfy_arcase.value,3)="FCG" or left(reg.tfy_arcase.value,3)="FCI" then
	if reg.tfzd_issue_no.value = empty then	
     MsgBox "���U���Ƥ��o���ťաI", 64, "Sorry!"
     settab 3
     reg.tfzd_issue_no.focus
     Exit function  
	end if
End if	

	If reg.tfy_case_stat.value="NN" then
		reg.tfzb_seq.value = reg.New_seq.value
		reg.tfzb_seq1.value = reg.New_seq1.value
	Elseif reg.tfy_case_stat.value="SN" then
		reg.tfzb_seq.value = reg.New_Ass_seq.value
		reg.tfzb_seq1.value = reg.New_Ass_seq1.value
		If reg.New_Ass_seq.value = empty then
		   msgbox "�ץ�s�����o���ťաA�Э��s��J"
		   settab 3
		   reg.New_Ass_seq.focus
		   exit Function
		End if
		If reg.New_Ass_seq1.value = empty then
		   msgbox "�ץ�s���ƽX���o���ťաA�Э��s��J"
		   settab 3
		   reg.New_Ass_seq1.focus
		   exit Function
		End if
	Elseif	reg.tfy_case_stat.value="OO" then
		reg.tfzb_seq.value = reg.Old_seq.value
		reg.tfzb_seq1.value = reg.Old_seq1.value
		If reg.Old_seq.value = empty then
		   msgbox "��ץ��®��ܧ�ɡA�п�J�y�ץ�s���z�Ϋ��U�y�T�w�z�H���o�ԲӸ��!"
		   settab 3
		   reg.Old_seq.focus
		   exit Function
		End if							
	End if
	
	'�j���׽дڵ��O�ˬd
	if reg.tfzb_seq1.value = "M" and reg.tfy_ar_mark.value <> "X" then 
		MsgBox "���ץ󬰤j����, �дڵ��O�г]�w���j���i�f��!!", 64, "Sorry!" 
		settab 2
		reg.tfy_ar_mark.focus 
		Exit function
	elseIF reg.tfzb_seq1.value <> "M" and reg.tfy_ar_mark.value = "X" then 
		MsgBox "�дڵ��O�]�w���j���i�f�סA�ץ�s���ƽX�г]�w��M_�j���� !!", 64, "Sorry!" 
		settab 3
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
if left(reg.tfy_Arcase.value,3)<>"FC3" then
		'gname="reg.tfzr_class.value"
		'kname="reg.tfzr_class_count.value"
		'if eval(gname)= empty or eval(kname) = empty then
		'	msgbox "�п�J���w�ϥΰӫ~/�A�����O�B�W��!!"
		'	settab 3
		'	execute "reg.tfzr_class_count.focus"
		'	exit function
		'end if	
	execute "pname=reg.tfzr_class_count.value"	'������w���O�`��
	IF eval(pname)<>empty then
		'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
		if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
			for z=1 to eval(pname)
				execute "gname=reg.class1"&z&".value"
				execute "pname=reg.good_name1"&z&".value"
				if pname<>empty and gname=empty  then
					msgbox "�п�J���O!!!"
					settab 3
					execute "reg.class1"&z&".focus"
					exit function
				end if
				if gname<>empty and reg.tfzr_class_type(0).checked then
					if cint(gname) < 0 or cint(gname) > 45 then
						Msgbox "�ϥ����O"&z&"���Ű�ڤ���(001~045)�C"
						settab 3
						execute "reg.class1"&z&".focus"
						exit function
					end if
	     		end if
			next		
		end if	
	End IF	
	'���w���O�ˬd
	execute "pname=reg.tfzr_class_count.value"	'������w���O�`��
	if pname<>empty then
		'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
		if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
			for z=1 to pname
				for j=1 to pname
					if z<>j then
						execute "gname=reg.class1"&z&".value"
						execute "kname=reg.class1"&j&".value"
						if gname<>empty  then
							if gname=kname then
							   Msgbox "�ӫ~���O����,�Э��s��J!!!"
							   settab 3
							   execute "reg.class1"&j&".focus"
							   exit function
							end if
						end if
					end if
					execute "kname=reg.class1"&j&".value"
					if kname<>empty and reg.tfzr_class_type(0).checked then
						if cint(kname) < 0 or cint(kname) > 45 then
							Msgbox "�ϥ����O"&j&"���Ű�ڤ���(001~045)�C"
							settab 3
							execute "reg.class1"&j&".focus"
							exit function
						end if
					end if
				next
			next
		end if	
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
					settab 3
					execute "reg.tfzr_class_count.focus"
					exit function
				end if
			end if
	end if	

else
for u=2 to 2
	'execute "gname=reg.tft3_class"&u&".value"
	'execute "kname=reg.tft3_class_count"&u&".value"
	'	if gname= empty or kname = empty then
	'		msgbox "�п�J���w�ϥΰӫ~/�A�����O�B�W��!!"
	'		settab 9
	'		execute "reg.tft3_class_count"&u&".focus"
	'		exit function
	'	end if	
	'���O�ˬd
	execute "pname=reg.tft3_class_count"&u&".value"	'������w���O�`��
	IF eval(pname)<>empty then
		'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
		if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
			for f=1 to eval(pname)
				execute "gname=reg.class3"&u&f&".value"
				execute "pname=reg.good_name3"&u&f&".value"
				if pname<>empty and gname=empty  then
					msgbox "�п�J���O!!!"
					settab 9
					execute "reg.class3"&u&f&".focus"
					exit function
				end if
				if gname<>empty and reg.tft3_class_type2(0).checked then
					if cint(gname) < 0 or cint(gname) > 45 then
						Msgbox "�ϥ����O"&z&"���Ű�ڤ���(001~045)�C"
						settab 9
						execute "reg.class3"&u&f&".focus"
						exit function
					end if
	     		end if
			next		
		End IF		
	end if	
	'���w���O�ˬd
	execute "pname=reg.tft3_class_count"&u&".value"	'������w���O�`��
	if pname<>empty then
		'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
		if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
			for z=1 to pname
				for j=1 to pname
					if z<>j then
						execute "gname=reg.class3"&u&z&".value"
						execute "kname=reg.class3"&u&j&".value"
						if gname<>empty  then
							if gname=kname then
								Msgbox "�ӫ~���O����,�Э��s��J!!!"
								settab 9
								execute "reg.class3"&u&j&".focus"
								exit function
							end if
						end if
					end if
					execute "kname=reg.class3"&u&j&".value"
					if kname<>empty and reg.tft3_class_type2(0).checked then
						if cint(kname) < 0 or cint(kname) > 45 then
							Msgbox "�ϥ����O"&j&"���Ű�ڤ���(001~045)�C"
							settab 9
							execute "reg.class3"&u&j&".focus"
							exit function
						end if
					end if
				next
			next
		end if	
	end if	
next
				
end if
'***���w���O�ƥ��ˬd
v=split(reg.tfy_Arcase.value,"&")
arcase=v(0)
prt_code=v(1)
if ubound(v)=2 then
   pagt_no=v(2)
else
   'pagt_no="A05"
   'pagt_no="A07"	'2008/12/16�]��98�~�ץX�W�N�z�H�קאּA07��&��&�L
   'pagt_no="A09"	'2013/7/17�]��102�~�ץX�W�N�z�H�קאּA09��&��
   pagt_no=get_tagtno("N")	'2015/10/21�]��104�~�ץX�W�N�z�H�ק�ç���cust_code.code_type=Tagt_no and mark=N�w�]�X�W�N�z�H
end if  
x=0
select case left(reg.tfy_arcase.value,4)
case "FC1&","FC10","FC9&","FCA&","FCB&","FCF&"
	
	
	if reg.tft1_mod_count11.value<>empty then
		for i=1 to reg.tft1_mod_count11.value
			execute "f=reg.new_no1"&i&".value"
			if f<>empty then
				x=x+1
				execute "reg.ctrlcnt"&mid(prt_code,3,1)&"1.value=x"
			end if
		next 
		  kname="reg.tft1_mod_count"&mid(prt_code,3,1)&"1.value"
		  gname="reg.ctrlcnt"&mid(prt_code,3,1)&"1.value"
		  class_cnt=eval(kname)
		  ctrlcnt=eval(gname)
			    
			    if class_cnt <> ctrlcnt then
					answer=msgbox("���w���(�@ "&eval(kname)&" ��)�P��J���(�@ "& eval(gname) &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w��Ʀ@ "& eval(gname) &" ���H",vbYesNo+vbdefaultbutton2,"�T�{���w���")
					if answer = vbYes then
						execute "reg.tft1_mod_count"&mid(prt_code,3,1)&"1.value=ctrlcnt"
					else
						settab mid(prt_code,3,1)+6
						execute "reg.tft1_mod_count"&mid(prt_code,3,1)&"1.focus"
						exit function
					end if
				end if
	end if
    old_no_flag="N"
    for apnum=1 to reg.FC1_apnum.value
        if eval("reg.dbmo1_old_no" & apnum & ".value") <> empty then
           old_no_flag="Y"
           exit for
        end if
    next
	if old_no_flag="Y" then
		if reg.tfzr_mod_ap.checked=false then
			msgbox "���ӽ��v�Q�����P�A�ФĿ��ܧ�ƶ��I�I"
			settab 7
			reg.tfzr_mod_ap.focus
			exit function
		end if
	end if
	'if reg.dbmo1_old_no.value<>empty then
	'	IF	reg.tfy_case_stat.value="OO" then
	'		msgbox "�ܧ��ӽФH��ơA�ץ�������i���®סA�Э��s��J�I"
	'		settab 3
	'		reg.tfy_case_stat.focus
	'		exit function
	'	End IF
	'end if
case "FC11","FC5&","FC7&","FCH&"
	
	
	old_no_flag="N"
    for apnum=1 to reg.FC1_apnum.value
        if eval("reg.dbmo1_old_no" & apnum & ".value") <> empty then
           old_no_flag="Y"
           exit for
        end if
    next
	if old_no_flag="Y" then
		if reg.tfzr1_mod_ap.checked=false then
			msgbox "���ӽ��v�Q�����P�A�ФĿ��ܧ�ƶ��I�I"
			settab 8
			reg.tfzr1_mod_ap.focus
			exit function
		end if
	end if
	
Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
	
	
case "FC3&"
	
	for j=1 to 2
		kname="reg.tft3_class_count"&j&".value"
		gname="reg.ctrlcount3"&j&".value"
		class_cnt=eval(kname)
		ctrlcnt=eval(gname)
		if class_cnt <> ctrlcnt then
			select case j 
			case "1"
				errname="�����Y"
			case "2"
				errname="���Y����w"
			end Select
			answer=msgbox(errname&"�ӫ~(�A��)�W�٫��w���(�@ "&eval(kname)&" ��)�P��J���(�@ "& eval(gname) &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w��Ʀ@ "& eval(gname) &" ���H",vbYesNo+vbdefaultbutton2,"�T�{���w���")
			if answer = vbYes then
				execute "reg.tft3_class_count"&j&".value=" & ctrlcnt
			else
				settab mid(prt_code,3,1)+6
				execute "reg.tft3_class_count"&j&".focus"
				exit function
			end if
		end if
	next 
case "FC4&"
	
end Select

'***�ܧ󶵥�*********************
select case Left(reg.tfy_arcase.value,4)
case "FC1&","FC10","FC9&","FCA&","FCB&"
	'FC1form
	if reg.tfzr_mod_ap.checked=true then
		reg.tfg1_mod_ap.value= "Y"
	else
		reg.tfg1_mod_ap.value= "N"
	end if
	if reg.tfzr_mod_aprep.checked=true then
		reg.tfg1_mod_aprep.value= "Y"
	else
		reg.tfg1_mod_aprep.value= "N"
	end if
	if reg.tfzr_mod_agt.checked=true then
		reg.tfg1_mod_agt.value= "Y"
	else
		reg.tfg1_mod_agt.value= "N"
	end if
	if reg.tfzr_mod_apaddr.checked=true then
		reg.tfg1_mod_apaddr.value= "Y"
	else
		reg.tfg1_mod_apaddr.value= "N"
	end if
	if reg.tfzr_mod_agtaddr.checked=true then
		reg.tfg1_mod_agtaddr.value= "Y"
	else
		reg.tfg1_mod_agtaddr.value= "N"
	end if
	if reg.tfzr_mod_oth.checked=true then
		reg.tfg1_mod_oth.value= "Y"
	else
		reg.tfg1_mod_oth.value= "N"
	end if
	if reg.tfzr_mod_oth1.checked=true then
		reg.tfg1_mod_oth1.value= "Y"
	else
		reg.tfg1_mod_oth1.value= "N"
	end if
	if reg.tfzr_mod_oth2.checked=true then
		reg.tfg1_mod_oth2.value= "Y"
	else
		reg.tfg1_mod_oth2.value= "N"
	end if
	if reg.tfzr_mod_claim1.checked=true then
		reg.tfg1_mod_claim1.value= "Y"
	else
		reg.tfg1_mod_claim1.value= "N"
	end if
case "FC11","FC5&","FC7&","FCH&"
	'FC11form
	if reg.tfzr1_mod_ap.checked=true then
		reg.tfg1_mod_ap.value= "Y"
	else
		reg.tfg1_mod_ap.value= "N"
	end if
	if reg.tfzr1_mod_aprep.checked=true then
		reg.tfg1_mod_aprep.value= "Y"
	else
		reg.tfg1_mod_aprep.value= "N"
	end if
	if reg.tfzr1_mod_agt.checked=true then
		reg.tfg1_mod_agt.value= "Y"
	else
		reg.tfg1_mod_agt.value= "N"
	end if
	if reg.tfzr1_mod_apaddr.checked=true then
		reg.tfg1_mod_apaddr.value= "Y"
	else
		reg.tfg1_mod_apaddr.value= "N"
	end if
	if reg.tfzr1_mod_agtaddr.checked=true then
		reg.tfg1_mod_agtaddr.value= "Y"
	else
		reg.tfg1_mod_agtaddr.value= "N"
	end if
	if reg.tfzr1_mod_oth.checked=true then
		reg.tfg1_mod_oth.value= "Y"
	else
		reg.tfg1_mod_oth.value= "N"
	end if
	if reg.tfzr1_mod_oth1.checked=true then
		reg.tfg1_mod_oth1.value= "Y"
	else
		reg.tfg1_mod_oth1.value= "N"
	end if
	if reg.tfzr1_mod_oth2.checked=true then
		reg.tfg1_mod_oth2.value= "Y"
	else
		reg.tfg1_mod_oth2.value= "N"
	end if
	if reg.tfzr1_mod_claim1.checked=true then
		reg.tfg1_mod_claim1.value= "Y"
	else
		reg.tfg1_mod_claim1.value= "N"
	end if
case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
	'FC2form
	if reg.tfop_mod_oth.checked=true then
		reg.tfg2_mod_oth.value= "Y"
	else
		reg.tfg2_mod_oth.value= "N"
	end if
	if reg.tfop_mod_oth1.checked=true then
		reg.tfg2_mod_oth1.value= "Y"
	else
		reg.tfg2_mod_oth1.value= "N"
	end if
		
	if reg.tfop_mod_dmt.checked=true then
		reg.tfg2_mod_dmt.value= "Y"
	else
		reg.tfg2_mod_dmt.value= "N"
	end if
	if reg.tfop_mod_claim1.checked=true then
		reg.tfg2_mod_claim1.value= "Y"
	else
		reg.tfg2_mod_claim1.value= "N"
	end if
	if reg.tfop_mod_claim2.checked=true then
		reg.tfg2_mod_claim2.value= "Y"
	else
		reg.tfg2_mod_claim2.value= "N"
	end if
	if reg.tfop_mod_agt.checked=true then
		reg.tfg2_mod_agt.value= "Y"
	else
		reg.tfg2_mod_agt.value= "N"
	end if
	if Left(reg.tfy_arcase.value,4) = "FCC&" then
	   if reg.tfg2_mod_agt.value = "Y" then
	      if reg.tfg2_mod_agttype(1).checked then
	      else
	         msgbox "�����U�ƶ��ܧ�(�s�W�N�z�H)�A�N�z�H���ʽ��I��u�s�W�v�I"
	         exit function
	      end if
	   else
	       msgbox "�����U�ƶ��ܧ�(�s�W�N�z�H)�A�Щ�N�z�H��ƫe�Ŀ�I"
	       exit function  
	   end if
	end if
	if Left(reg.tfy_arcase.value,4) = "FCD&" then
	   if reg.tfg2_mod_agt.value = "Y" then
	      if reg.tfg2_mod_agttype(2).checked then
	      else
	         msgbox "�����U�ƶ��ܧ�(�M�P�N�z�H)�A�N�z�H���ʽ��I��u�M�P�v�I"
	         exit function
	      end if
	   else
	       msgbox "�����U�ƶ��ܧ�(�M�P�N�z�H)�A�Щ�N�z�H��ƫe�Ŀ�I"
	       exit function  
	   end if
	end if
	
case "FC21","FC8&","FC6&","FCI&"
	'FC21form
	if reg.tfop1_mod_oth.checked=true then
		reg.tfg2_mod_oth.value= "Y"
	else
		reg.tfg2_mod_oth.value= "N"
	end if
	if reg.tfop1_mod_oth1.checked=true then
		reg.tfg2_mod_oth1.value= "Y"
	else
		reg.tfg2_mod_oth1.value= "N"
	end if
	
	if reg.tfop1_mod_dmt.checked=true then
		reg.tfg2_mod_dmt.value= "Y"
	else
		reg.tfg2_mod_dmt.value= "N"
	end if
	if reg.tfop1_mod_claim1.checked=true then
		reg.tfg2_mod_claim1.value= "Y"
	else
		reg.tfg2_mod_claim1.value= "N"
	end if
	if reg.tfop1_mod_claim2.checked=true then
		reg.tfg2_mod_claim2.value= "Y"
	else
		reg.tfg2_mod_claim2.value= "N"
	end if
	if reg.tfop1_mod_agt.checked=true then
		reg.tfg2_mod_agt.value= "Y"
	else
		reg.tfg2_mod_agt.value= "N"
	end if
	if reg.tfop1_mod_agttype(0).checked=true then reg.tfg2_mod_agttype(0).checked=true
	if reg.tfop1_mod_agttype(1).checked=true then reg.tfg2_mod_agttype(1).checked=true
	if reg.tfop1_mod_agttype(2).checked=true then reg.tfg2_mod_agttype(2).checked=true
case "FC3&"
	'FC3form
	if reg.tft3_class1.value <> empty then
		reg.tfg3_mod_class.value= "Y"
	else
		reg.tfg3_mod_class.value= "N"
	end if
case "FC4&"
end select 

'*****�ץ󤺮e
	select case Left(reg.tfy_arcase.value,4)
		Case "FC1&","FC10","FC9&","FCA&","FCB&","FCF&"
			'if reg.ttgp_SD(0).checked=true then
			'	reg.tft1_mod_type.value="Single"
			'elseif reg.ttgp_SD(1).checked=true then
			'	reg.tft1_mod_type.value="Double"
			'end if
			'�X�W�N�z�H�ˬd
			apclass_flag="N"
			for capnum=1 to reg.apnum.value
				IF left(eval("reg.ttg1_apclass"& capnum &".value"),1)="C" then
					apclass_flag="C"	
				End IF
			next
	 		if apclass_flag="C" then
	 		      if check_agtno("C",reg.ttg1_agt_no.value)=true then 
	 			     settab 7
	 			 	 reg.ttg1_agt_no.focus
	 			  	 exit function
	 			  end if
	 		else	  
	 		   if trim(reg.ttg1_agt_no.value)<>trim(pagt_no) then
	 		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 		       if ans=vbNo then
	 		          settab 7
	 		          reg.ttg1_agt_no.focus
	 		          exit function
	 		       end if
	 		   end if   
	 		end if
	 		if left(reg.tfy_arcase.value,4) = "FCA&" then
	 		   if trim(reg.FC1_add_agt_no.value)=empty then
	 		      msgbox "���ӽШƶ��ܧ�(�s�W�N�z�H)�A�п�ܷs�W�N�z�H�I"
	 		      settab 7
	 		      reg.FC1_add_agt_no.focus
	 		      exit function
	 		   end if
	 		end if 
			reg.tfzd_agt_no.value=reg.ttg1_agt_no.value
		Case "FC11","FC5&","FC7&","FCH&"
			'�X�W�N�z�H�ˬd
			apclass_flag="N"
			for capnum=1 to reg.apnum.value
				IF left(eval("reg.ttg1_apclass"& capnum &".value"),1)="C" then
					apclass_flag="C"	
				End IF
			next
	 		if apclass_flag="C" then
	 			  if check_agtno("C",reg.ttg11_agt_no.value)=true then 
	 			     settab 8
	 			 	 reg.ttg11_agt_no.focus
	 			  	 exit function
	 			  end if
	 		else	  
	 		   if trim(reg.ttg11_agt_no.value)<>trim(pagt_no) then
	 		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 		       if ans=vbNo then
	 		          settab 8
	 		          reg.ttg11_agt_no.focus
	 		          exit function
	 		       end if
	 		   end if   
	 		end if
			reg.tfzd_agt_no.value=reg.ttg11_agt_no.value
		Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
			'�X�W�N�z�H�ˬd
			'msgbox reg.ttg2_apclass.value
			apclass_flag="N"
			for capnum=1 to reg.fc0_apnum.value
				IF left(eval("reg.ttg2_apclass"& capnum &".value"),1)="C" then
					apclass_flag="C"	
				End IF
			next
	 		if apclass_flag="C" then
	 		      if check_agtno("C",reg.ttg2_agt_no.value)=true then
	 			     settab 9
	 			 	 reg.ttg2_agt_no.focus
	 			  	 exit function
	 			  end if
	 		else	  
	 		   if trim(reg.ttg2_agt_no.value)<>trim(pagt_no) then
	 		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 		       if ans=vbNo then
	 		          settab 9
	 		          reg.ttg2_agt_no.focus
	 		          exit function
	 		       end if
	 		   end if   
	 		end if
			reg.tfzd_agt_no.value=reg.ttg2_agt_no.value
		Case "FC21","FC6&","FC8&","FCI&"
			'�X�W�N�z�H�ˬd
			apclass_flag="N"
			for capnum=1 to reg.fc0_apnum.value
				IF left(eval("reg.ttg2_apclass"& capnum &".value"),1)="C" then
					apclass_flag="C"	
				End IF
			next	
	 		if apclass_flag="C" then
	 			  if check_agtno("C",reg.ttg21_agt_no.value)=true then	
	 			     settab 10
	 			 	 reg.ttg21_agt_no.focus
	 			  	 exit function
	 			  end if
	 		else	  
	 		   if trim(reg.ttg21_agt_no.value)<>trim(pagt_no) then
	 		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 		       if ans=vbNo then
	 		          settab 10
	 		          reg.ttg21_agt_no.focus
	 		          exit function
	 		       end if
	 		   end if   
	 		end if
			reg.tfzd_agt_no.value=reg.ttg21_agt_no.value
		Case "FC3&"
			'�X�W�N�z�H�ˬd
			apclass_flag="N"
			for capnum=1 to reg.fc_apnum.value
				IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
					apclass_flag="C"	
				End IF
			next	
	 		if apclass_flag="C" then
	 		      if check_agtno("C",reg.ttg3_agt_no.value)=true then
	 			     settab 11
	 			 	 reg.ttg3_agt_no.focus
	 			  	 exit function
	 			  end if
	 		else	  
	 		   if trim(reg.ttg3_agt_no.value)<>trim(pagt_no) then
	 		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 		       if ans=vbNo then
	 		          settab 11
	 		          reg.ttg3_agt_no.focus
	 		          exit function
	 		       end if
	 		   end if   
	 		end if
			reg.tfzd_agt_no.value=reg.ttg3_agt_no.value					
		Case "FC4&"
			'if reg.ttg4_SD(0).checked=true then
			'	reg.tft4_mod_type.value="Single"
			'elseif reg.ttg4_SD(1).checked=true then
			'	reg.tft4_mod_type.value="Double"
			'end if
			'�X�W�N�z�H�ˬd
			apclass_flag="N"
			for capnum=1 to reg.fc_apnum.value
				IF left(eval("reg.apclass"& capnum &".value"),1)="C" then
					apclass_flag="C"	
				End IF
			next	
	 		if apclass_flag="C" then
	 		      if check_agtno("C",reg.ttg4_agt_no.value)=true then
	 		   	     settab 12
	 			 	 reg.ttg4_agt_no.focus
	 			  	 exit function
	 			  end if
	 		else	  
	 		   if trim(reg.ttg4_agt_no.value)<>trim(pagt_no) then
	 		       ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
	 		       if ans=vbNo then
	 		          settab 12
	 		          reg.ttg4_agt_no.focus
	 		          exit function
	 		       end if
	 		   end if   
	 		end if
			reg.tfzd_agt_no.value=reg.ttg4_agt_no.value					
			if reg.fr4_S_Mark(0).checked=true then
				reg.tfzd_Pul.value="2"
				reg.tfzd_S_Mark.value=""
			elseif reg.fr4_S_Mark(1).checked=true then
				reg.tfzd_Pul.value="2"
				reg.tfzd_S_Mark.value="S"
			end if
	End select	
main.chkEndBack()
	
	reg.F_tscode.disabled = false
	reg.tfy_case_stat.disabled=false
	reg.tfzd_tcn_mark.disabled = false
	reg.tfgp_seq.value = reg.tfzb_seq.value
	reg.tfgp_seq1.value= reg.tfzb_seq1.value
	
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

'�ܧ�@�צh�󱱨�	 
Select case left(reg.tfy_arcase.value,4)
	case "FC11","FC5&","FC7&","FCH&"
	IF reg.tot_num11.value=empty and reg.dseqa1.value<>empty  then
		reg.tot_num11.value="1"
	ElseIF reg.tot_num11.value=empty and reg.dseqa2.value<>empty  then
		reg.tot_num11.value="2"
	End IF
	if clng(reg.tot_num11.value)<=1 then
		Msgbox "�ܧ�ץ�п�J�h��!!!"
		settab 8
		reg.tot_num11.focus
		exit function
	End IF
	if trim(reg.tot_num11.value)<>empty then
	x=0
	f=0
		for i=1 to reg.tot_num11.value
			execute "f=trim(reg.appl_namea"&i&".value)"
			execute "g=trim(reg.dseqa"&i&".value)"
			if f<>empty or g<>empty then
				x=x+1
				execute "reg.ctrlcnt111.value=x"
			end if
		next
		  tot_num=cint(trim(reg.tot_num11.value))
		  ctrlcnt=cint(trim(reg.ctrlcnt111.value))
			    if tot_num <> ctrlcnt then
					answer=msgbox("�ܧ���(�@ "&reg.tot_num11.value&" ��)�P�]�t�D�n�שʿ�J���(�@ "& ctrlcnt &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w��Ʀ@ "& ctrlcnt &" ��H",vbYesNo+vbdefaultbutton2,"�T�{���w���")
					if answer = vbYes then
						execute "reg.tot_num11.value=ctrlcnt"
					else
						settab 8
						execute "reg.tot_num11.focus"
						exit function
					end if
				end if
	end if
		reg.nfy_tot_num.value=reg.tot_num11.value
	case "FC21","FC6&","FC8&","FCI&"
		if clng(reg.tot_num21.value)<=1 then
			Msgbox "�ܧ�ץ�п�J�h��!!!"
			settab 10
			reg.tot_num21.focus
			exit function
		End IF
		IF reg.tot_num21.value=empty and reg.dseqb1.value<>empty  then
			reg.tot_num21.value="1"
		Elseif reg.tot_num21.value=empty and reg.dseqb2.value<>empty then
			reg.tot_num21.value="2"
		End IF
		
		if trim(reg.tot_num21.value)<>empty then
		x=0
		f=0
			for i=1 to reg.tot_num21.value
			execute "f=trim(reg.appl_nameb"&i&".value)"
			execute "g=trim(reg.dseqb"&i&".value)"
				if f<>empty or g<>empty then
					x=x+1
					execute "reg.ctrlcnt211.value=x"
				end if
			next
			tot_num=cint(trim(reg.tot_num21.value))
			ctrlcnt=cint(trim(reg.ctrlcnt211.value))
			    if tot_num <> ctrlcnt then
					answer=msgbox("�ܧ���(�@ "&reg.tot_num21.value&" ��)�P�]�t�D�n�שʿ�J���(�@ "& ctrlcnt &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w��Ʀ@ "& ctrlcnt &" ��H",vbYesNo+vbdefaultbutton2,"�T�{���w���")
					if answer = vbYes then
						execute "reg.tot_num21.value=ctrlcnt"
					else
						settab 10
						execute "reg.tot_num21.focus"
						exit function
					end if
				end if
	end if
		reg.nfy_tot_num.value=reg.tot_num21.value
	case else
		reg.nfy_tot_num.value=1
End Select 
i=1
x=1
Select case left(reg.tfy_arcase.value,4)
	case "FC11","FC5&","FC7&","FCH&"
		for x=1 to reg.nfy_tot_num.value
			if eval("reg.case_stat1a"&x&"(1).checked")=True then
				if eval("reg.keydseqa"&x&".value")="N" then
					msgbox "���ҽs��"&x&"�ܰʹL�A�Ы�[�T�w]���s�A���s������!!!"
					settab 8
					gname="reg.btndseq_oka"&x&".focus"
					execute gname
					exit function
				End IF
			End IF
		next
	case "FC21","FC6&","FC8&","FCI&"
		for x=1 to reg.nfy_tot_num.value
			if eval("reg.case_stat1b"&x&"(1).checked")=True then
				if eval("reg.keydseqb"&x&".value")="N" then
					msgbox "���ҽs��"&x&"�ܰʹL�A�Ы�[�T�w]���s�A���s������!!!"
					settab 10
					gname="reg.btndseq_okb"&x&".focus"
					execute gname
					exit function
				End IF
			End IF
		next
End Select 	

'�����ˬd
Select case left(reg.tfy_arcase.value,4)
	Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
		if reg.O_item21.value = empty and (reg.O_item22(0).checked=false and reg.O_item22(1).checked=false and reg.O_item22(2).checked=false and reg.O_item22(3).checked=false and reg.O_item22(4).checked=false) then
		elseif reg.O_item21.value = empty and (reg.O_item22(0).checked=true or reg.O_item22(1).checked=true or reg.O_item22(2).checked=true or reg.O_item22(3).checked=true or reg.O_item22(4).checked=true) then
			answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
					if answer <> vbYes then
						'execute "reg.tfzr_class_count.value=" & ctrlcnt
					'else
						settab 9
						execute "reg.O_item21.focus"
						exit function
					end if
		end if
	Case "FC21","FC6&","FC8&"
		if reg.O_item211.value = empty and (reg.O_item221(0).checked=false and reg.O_item221(1).checked=false and reg.O_item221(2).checked=false and reg.O_item221(3).checked=false and reg.O_item221(4).checked=false) then
		elseif reg.O_item211.value = empty and (reg.O_item221(0).checked=true or reg.O_item221(1).checked=true or reg.O_item221(2).checked=true or reg.O_item221(3).checked=true or reg.O_item221(4).checked=true) then
			answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
					if answer <> vbYes then
						'execute "reg.tfzr_class_count.value=" & ctrlcnt
					'else
						settab 10
						execute "reg.O_item211.focus"
						exit function
					end if
		end if
	Case "FC3&"
		if reg.O_item31.value = empty and (reg.O_item32(0).checked=false and reg.O_item32(1).checked=false and reg.O_item32(2).checked=false and reg.O_item32(3).checked=false and reg.O_item32(4).checked=false) then
		elseif reg.O_item31.value = empty and (reg.O_item32(0).checked=true or reg.O_item32(1).checked=true or reg.O_item32(2).checked=true or reg.O_item32(3).checked=true or reg.O_item32(4).checked=true) then
			answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
					if answer <> vbYes then
						'execute "reg.tfzr_class_count.value=" & ctrlcnt
					'else
					settab 11
						execute "reg.O_item31.focus"
						exit function
					end if
		end if	
End Select	 
'****��L���O�зǮɡA��ȲM��
	if reg.anfees.value = "N" then 
	   reg.nfy_Discount.value =""	
	   reg.tfy_discount_remark.value=""	'2016/5/30�W�[�馩�z��
	end if   
	reg.action="Brt11AddA6.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
