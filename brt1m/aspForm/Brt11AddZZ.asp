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

    //���״_���ˬd
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
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum","apclass","tfg2_agt_no1") == false) return false;
	elseIF left(reg.tfy_arcase.value,3)="AD7" or left(reg.tfy_arcase.value,3)="AD8" then
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum","apclass","tfp4_agt_no") == false) return false;
	elseIF left(reg.tfy_arcase.value,3)="FOF" then
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum","apclass","tfzf_agt_no1") == false) return false;
	elseIF left(reg.tfy_arcase.value,3)="FB7" then
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum","apclass","tfb7_agt_no1") == false) return false;
	Else
		//�X�W�N�z�H�ˬd
		if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;
	end if
 
	reg.action="Brt11AddZZ.asp"	
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
