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

    //�s/�®׸�
    if (main.chkNewOld() == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");
	
	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value
	
    //�D�ɰӫ~���O�ˬd
    if (main.chkGood() == false) return false;

'****���Ϋ�ӽЮש�
Select case left(reg.tfy_arcase.value,3)
Case "FD1"
		IF reg.tfg1_div_arcase.value=empty then
			Msgbox "�п�ܤ��Ϋ�ש�!!"
			settab 5
			execute "reg.tfg1_div_arcase.focus"
			exit Function
		Else
			reg.tfy_div_arcase.value=reg.tfg1_div_arcase.value
		End IF

		//�X�W�N�z�H�ˬd
    	if (main.chkAgt("apnum","apclass","ttg1_agt_no") == false) return false;

		IF reg.tot_num1.value=empty then
			Msgbox "�п�J���Υ��!!"
			settab 5
			execute "reg.tot_num1.focus"
			exit function
		Else
			reg.nfy_tot_num.value=reg.tot_num1.value
		End IF
		reg.tfzd_remark1.value=empty 
		IF reg.ttz1_Z1.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz1_Z1.value&"|"
		End IF
		IF reg.ttz1_Z1C.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz1_Z1C.value&"|"
		End IF
		IF reg.ttz1_Z2.checked=true then
			IF reg.ttz1_Z2C.value=empty then
				Msgbox "����G���Ŀ�A�п�J�����Υ�Ƥ����ΥӽЮѰƥ�����"
				settab 5 
				reg.ttz1_Z2C.focus
				exit function
			Else
				reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz1_Z2.value&";"& reg.ttz1_Z2C.value&"|"
			End IF
		End IF
		IF reg.ttz1_Z3.checked=true then
			IF reg.ttz1_Z2C.value=empty then
				Msgbox "����T���Ŀ�A�п�J�Ϋᤧ�Ӽе��U�ӽЮѥ����Ψ����������"
				settab 5 
				reg.ttz1_Z2C.focus
				exit function
			Else
				reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz1_Z3.value&";"& reg.ttz1_Z3C.value&"|"
			End IF
		End IF
		IF reg.ttz1_Z4.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz1_Z4.value&"|"
		End IF
		IF reg.ttz1_Z9.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz1_Z9.value & ";" & trim(reg.ttz1_Z9t.value) & "|"
		End IF
		'***���w���O�ƥ��ˬd
		a=1
		x=0
			for i=1 to reg.nfy_tot_num.value
				execute "f=reg.FD1_class_count"&i&".value"
				if f<>empty then
					x=x+1
					execute "reg.ctrlcnt1.value=x"
				end if
			next
			IF trim(reg.ctrlcnt1.value)="" or trim(reg.ctrlcnt1.value)=empty then
				msgbox "�����Υ�ơA���L��J���ΰӫ~/�A�����O�B�W�١B�ҩ����e�μЪ��A�п�J�I�I�I"
				settab 5
				execute "reg.FD1_class_count1.focus"
				exit function
			End IF 
			execute "pname=reg.tot_num1.value"
			if pname<>empty then
				kname=pname
				execute "gname=reg.ctrlcnt1.value"
				class_cnt=kname
				ctrlcnt=gname
				    if class_cnt <> ctrlcnt then
						answer=msgbox("���Υ��(�@ "&kname&" ��)�P��J���Ϋ����O����(�@ "& gname &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���Ϋ����O���ئ@ "& gname &" ���H",vbYesNo+vbdefaultbutton2,"�T�{���Υ��")
						if answer = vbYes then
							execute "reg.nfy_tot_num.value=" & ctrlcnt
						else
							settab 5
							execute "reg.tot_num1.focus"
							exit function
						end if
					end if
			end if
		a=1
		For a=1 to reg.nfy_tot_num.value
		x=0
		i=0
		execute "aname=reg.FD1_class_count"&a&".value"
			for i=1 to aname
				execute "f=reg.classa"&a&i&".value"
				if f<>empty then
					x=x+1
					execute "reg.FD1_ctrlcnt"&a&".value=x"
				end if
			Next
			execute "pname=reg.FD1_class_count"&a&".value"
			if pname<>empty then
				kname=pname
				execute "gname=reg.FD1_ctrlcnt"&a&".value"
				class_cnt=kname
				ctrlcnt=gname
				    if class_cnt <> ctrlcnt then
						answer=msgbox("���Ϋ���w�ϥΰӫ~���O����"&a&"(�@ "&kname&" ��)�P��J���w�ϥΰӫ~(�@ "& gname &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w�ϥΰӫ~�@ "& gname &" ���H",vbYesNo+vbdefaultbutton2,"�T�{���Ϋ�ӫ~���O����")
						if answer = vbYes then
							execute "reg.FD1_class_count"&a&".value=" & ctrlcnt
						else
							settab 5
							execute "reg.FD1_class_count"&a&".focus"
							exit function
						end if
					end if
			end if
		Next
		'�����ˬd
		if reg.O_item11.value = empty and (reg.O_item12(0).checked=false and reg.O_item12(1).checked=false and reg.O_item12(2).checked=false and reg.O_item12(3).checked=false and reg.O_item12(4).checked=false and reg.O_item12(5).checked=false) then
		elseif reg.O_item11.value = empty and (reg.O_item12(0).checked=true or reg.O_item12(1).checked=true or reg.O_item12(2).checked=true or reg.O_item12(3).checked=true or reg.O_item12(4).checked=true or reg.O_item12(5).checked=true) then
			answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
					if answer <> vbYes then
						settab 5
						execute "reg.O_item11.focus"
						exit function
					end if
		end if
		a=0
		For a=1 to reg.nfy_tot_num.value
			gname="reg.FD1_Marka"&a&"(0).checked"
			kname="reg.FD1_Marka"&a&"(1).checked"
			IF eval(gname)=false and eval(kname)=false then
				Msgbox "�п�ܤ���"&NumberToCh(a)&"�W�ٺ����G"
				settab 5
				execute "reg.FD1_Marka"&a&"(0).focus"
				exit function
			End IF
		Next
		For w=1 to reg.nfy_tot_num.value 
			execute "pname=reg.FD1_class_count"&w&".value"	'������w���O�`��
			for z=1 to eval(pname)
			for j=1 to eval(pname)
				if z<>j then
					execute "gname=reg.classa"&w&z&".value"
					execute "kname=reg.classa"&w&j&".value"
					if gname<>empty  then
						if gname=kname then
						   Msgbox "�ӫ~���O����,�Э��s��J!!!"
						   execute "reg.classa"&w&j&".focus"
						   exit function
						end if
					end if
				end if
			next
			next	
		next
Case "FD2","FD3"
		//�X�W�N�z�H�ˬd
    	if (main.chkAgt("apnum","apclass","ttg2_agt_no") == false) return false;

		IF reg.tot_num2.value=empty then
			Msgbox "�п�J���Υ��!!"
			settab 6
			execute "reg.tot_num2.focus"
			exit function
		Else
			reg.nfy_tot_num.value=reg.tot_num2.value
		End IF
		reg.tfzd_remark1.value=empty 
		IF reg.ttz2_Z1.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz2_Z1.value&"|"
		End IF
		IF reg.ttz2_Z1C.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz2_Z1C.value&"|"
		End IF
		IF reg.ttz2_Z2.checked=true then
			IF reg.ttz2_Z2C.value=empty then
				Msgbox "����G���Ŀ�A�п�J�����Υ�Ƥ����ΥӽЮѰƥ�����"
				settab 5 
				reg.ttz2_Z2C.focus
				exit function
			Else
				reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz2_Z2.value&";"& reg.ttz2_Z2C.value&"|"
			End IF
		End IF
		IF reg.ttz2_Z4.checked=true then
			reg.tfzd_remark1.value=reg.tfzd_remark1.value & reg.ttz2_Z4.value&"|"
		End IF
		'***���w���O�ƥ��ˬd
		a=1
		x=0
			for i=1 to reg.nfy_tot_num.value
				execute "f=reg.FD2_class_count"&i&".value"
				if f<>empty then
					x=x+1
					execute "reg.ctrlcnt2.value=x"
				end if
			next 
			IF trim(reg.ctrlcnt2.value)=empty or trim(reg.ctrlcnt2.value)="" then
				msgbox "�����Υ�ơA���L��J���ΰӫ~/�A�����O�B�W�١B�ҩ����e�μЪ��A�п�J�I�I�I"
				settab 6
				execute "reg.FD2_class_count1.focus"
				exit function
			End IF
			execute "pname=reg.tot_num2.value"
			if pname<>empty then
				kname=pname
				execute "gname=reg.ctrlcnt2.value"
				class_cnt=kname
				ctrlcnt=gname
				    if class_cnt <> ctrlcnt then
						answer=msgbox("���Υ��(�@ "&kname&" ��)�P��J���Ϋ����O����(�@ "& gname &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���Ϋ����O���ئ@ "& gname &" ���H",vbYesNo+vbdefaultbutton2,"�T�{���Υ��")
						if answer = vbYes then
							execute "reg.nfy_tot_num.value=" & ctrlcnt
						else
							settab 6
							execute "reg.tot_num2.focus"
							exit function
						end if
					end if
			end if
		a=1
		
		For a=1 to reg.nfy_tot_num.value
		x=0
		i=0
			execute "aname=reg.FD2_class_count"&a&".value"
			for i=1 to aname
				execute "f=reg.classb"&a&i&".value"
				if f<>empty then
					x=x+1
					execute "reg.FD2_ctrlcnt"&a&".value=x"
				end if
			Next
			execute "pname=reg.FD2_class_count"&a&".value"
			if pname<>empty then
				kname=pname
				execute "gname=reg.FD2_ctrlcnt"&a&".value"
				class_cnt=kname
				ctrlcnt=gname
				    if class_cnt <> ctrlcnt then
						answer=msgbox("���Ϋ���w�ϥΰӫ~���O����"&a&"(�@ "&kname&" ��)�P��J���w�ϥΰӫ~(�@ "& gname &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w�ϥΰӫ~�@ "& gname &" ���H",vbYesNo+vbdefaultbutton2,"�T�{���Ϋ�ӫ~���O����")
						if answer = vbYes then
							execute "reg.FD2_class_count"&a&".value=" & ctrlcnt
						else
							settab 6
							execute "reg.FD2_class_count"&a&".focus"
							exit function
						end if
					end if
			end if
		Next
		'�����ˬd
		if reg.O_item21.value = empty and (reg.O_item22(0).checked=false and reg.O_item22(1).checked=false and reg.O_item22(2).checked=false and reg.O_item22(3).checked=false and reg.O_item22(4).checked=false and reg.O_item22(5).checked=false) then
		elseif reg.O_item21.value = empty and (reg.O_item22(0).checked=true or reg.O_item22(1).checked=true or reg.O_item22(2).checked=true or reg.O_item22(3).checked=true or reg.O_item22(4).checked=true or reg.O_item22(5).checked=true) then
			answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
					if answer <> vbYes then
						settab 6
						execute "reg.O_item21.focus"
						exit function
					end if
		end if
		a=0
		For a=1 to reg.nfy_tot_num.value
			gname="reg.FD2_Markb"&a&"(0).checked"
			kname="reg.FD2_Markb"&a&"(1).checked"
			IF eval(gname)=false and eval(kname)=false then
				Msgbox "�п�ܤ���"&NumberToCh(a)&"�W�ٺ����G"
				settab 6
				execute "reg.FD2_Markb"&a&"(0).focus"
				exit function
			End IF
		Next
		For w=1 to reg.nfy_tot_num.value 
			execute "pname=reg.FD2_class_count"&w&".value"	'������w���O�`��
			for z=1 to eval(pname)
			for j=1 to eval(pname)
				if z<>j then
					execute "gname=reg.classb"&w&z&".value"
					execute "kname=reg.classb"&w&j&".value"
					if gname<>empty  then
						if gname=kname then
						   Msgbox "�ӫ~���O����,�Э��s��J!!!"
						   execute "reg.classb"&w&j&".focus"
						   exit function
						end if
					end if
				end if
			next
			next	
		next
End Select

    //���״_���ˬd
    if (main.chkEndBack() == false) return false;

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
 
	reg.action="Brt11AddA5.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
