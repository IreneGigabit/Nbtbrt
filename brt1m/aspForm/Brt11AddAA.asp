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
'****�Ƶ����
If reg.O_item1.value <> empty then
	IF isdate(reg.O_item1.value) = false then
		msgbox "���ˬd�Ƶ���� �A����榡�O�_���T!!"
		settab 5
		reg.O_item1.focus
		exit function
	End If
End If 	

IF reg.tfzd_Mark(0).checked=true then 	
	if trim(reg.tfzd_apply_no.value) = empty then	
	    MsgBox "�ӽи��Ƥ��i�H�ťաI", 64, "Sorry!"
	    settab 4
	    reg.tfzd_apply_no.focus
	    Exit function  
	end if
ElseIF reg.tfzd_Mark(1).checked=true then
	if trim(reg.tfzd_issue_no.value) = empty then	
	    MsgBox "���U���Ƥ��i�H�ťաI", 64, "Sorry!"
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
		   msgbox "��ץ��®��ҩ����ɡA�п�J�y�ץ�s���z�Ϋ��U�y�T�w�z�H���o�ԲӸ��!"
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
'�����ˬd
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false and reg.O_item2(4).checked=false) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true or reg.O_item2(4).checked=true) then
	answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
			if answer <> vbYes then
				'execute "reg.tfzr_class_count.value=" & ctrlcnt
			'else
				settab 5
				execute "reg.O_item1.focus"
				exit function
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
'*****�ץ󤺮e
if reg.tfgd_mod_claim1(0).checked=false and reg.tfgd_mod_claim1(1).checked=false then
'	msgbox "���I��M�δ���/�ӽе��U���!!!"
	'2007/9/1�s�ӽЮѨ����M�δ���/�ӽе��U����A�קאּ����
	'2012/7/1�s�ӽЮѨ����A�e�����áA�ק藍���ˬd
	'answer=msgbox("�M�δ���/�ӽе��U�������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{�M�δ���/�ӽе��U���")
	'if answer = vbNo then
	'   settab 5 
	'   reg.tfgd_mod_claim1(0).focus
	'   exit Function
	'end if   
else
	if reg.tfgd_mod_claim1(0).checked=true then
		If trim(reg.tfn1_term1.value) = empty then
			msgbox "�M�ΰ_�餣�o���ťաA�Э��s��J!!!"
			settab 5
			reg.tfn1_term1.focus
			exit Function
		else
			reg.tfg3_term1.value=reg.tfn1_term1.value
		End if
		If trim(reg.tfn1_term2.value) = empty then
			msgbox "�M�Ψ��餣�o���ťաA�Э��s��J!!!"
			settab 5
			reg.tfn1_term2.focus
			exit Function
		else
			reg.tfg3_term2.value=reg.tfn1_term2.value
		End if
	elseif reg.tfgd_mod_claim1(1).checked=true then
		If trim(reg.tfn2_term1.value) = empty then
			msgbox "�ӽФ餣�o���ťաA�Э��s��J"
			settab 5
			reg.tfn2_term1.focus
			exit Function
		else
			reg.tfg3_term1.value=reg.tfn2_term1.value
		End if
	end if
end if			
if reg.tfgd_tran_Mark(0).checked=false and reg.tfgd_tran_Mark(1).checked=false then
	msgbox "�п�J�ҩ��Ѻ���!!"
	settab 5
	reg.tfgd_tran_Mark(0).focus
	exit Function
end if
v=split(reg.tfy_Arcase.value,"&")
if ubound(v)=2 then
   pagt_no=v(2)
else
   'pagt_no="A05"
   'pagt_no="A07"	'2008/12/16�]��98�~�ץX�W�N�z�H�קאּA07��&��&�L
   'pagt_no="A09"	'2013/7/17�]��102�~�ץX�W�N�z�H�קאּA09��&��
   pagt_no=get_tagtno("N")	'2015/10/21�]��104�~�ץX�W�N�z�H�ק�ç���cust_code.code_type=Tagt_no and mark=N�w�]�X�W�N�z�H
end if
'�X�W�N�z�H�ˬd
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
      ans=msgbox("�X�W�N�z�H�P�שʹw�]�X�W�N�z�H���P�A�O�_�T�w���H",vbYesNo+vbdefaultbutton2,"�T�w�X�W�N�z�H")
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

'****��L���O�зǮɡA��ȲM��
	if reg.anfees.value = "N" then 
		reg.nfy_Discount.value =""
		reg.tfy_discount_remark.value=""	'2016/5/30�W�[�馩�z��
	end if	
	reg.action="Brt11AddAA.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
