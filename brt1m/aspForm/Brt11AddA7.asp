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
	IF left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6" then
		errName="���v�_��"
		errName1="���v����"
	Else
		errName="�פ���"
	End If
	If reg.tfg1_term1.value = empty then
	   IF (left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6") then
	       if reg.tfg1_mod_claim1(0).checked=true then
				msgbox errName&"���o���ť�,�Э��s��J!!"
				settab 5
				reg.tfg1_term1.focus
				exit Function
			end if
		else
			msgbox errName&"���o���ť�,�Э��s��J!!"
			settab 5
			reg.tfg1_term1.focus
			exit Function
		end if	
	End if
	

IF (left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6") and reg.tfg1_mod_claim1(0).checked=true then
	If reg.tfg1_term2.value = empty then
			msgbox errName1&"���o���ť�,�Э��s��J!!"
			settab 5
			reg.tfg1_term2.focus
			exit Function
	End if
End if
'�I��L�I���������ˬd
IF (left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6") and reg.tfg1_mod_claim1(1).checked=true then
   if reg.fl_term1.value=empty then
	   msgbox errName&"���o���ť�,�Э��s��J!!"
	   settab 5
	   reg.fl_term1.focus
	   exit Function
   end if
   reg.tfg1_term1.value=reg.fl_term1.value
end if
If reg.tfzd_mark(0).checked=false and reg.tfzd_mark(1).checked=false then
	msgbox "�п�J�ӽФH!!"
	settab 5
	reg.tfzd_mark(0).focus
	exit function
End If
'�����ˬd
'alert (reg.O_item2(5).value)
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false and reg.O_item2(4).checked=false and reg.O_item2(5).checked=false) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true or reg.O_item2(4).checked=true or reg.O_item2(5).checked=true) then
	answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
			if answer <> vbYes then
				settab 5
				execute "reg.O_item1.focus"
				exit function
			end if
end if
'***���v�ӫ~
if left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6" then
	if reg.tfl1_mod_type(0).checked=false and reg.tfl1_mod_type(1).checked=false then
		msgbox "�п�ܱ��v�ӫ~���������v�γ������v!!"
		settab 5
		reg.tfl1_mod_type(0).focus
		exit function
	end if
end if
if reg.mod_count.value<>empty or reg.mod_dclass.value<>empty then
   reg.tfg1_mod_class.value="Y"
else
   reg.tfg1_mod_class.value="N"
end if

//�X�W�N�z�H�ˬd
if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;

    //���״_���ˬd
    if (main.chkEndBack() == false) return false;

'���v�h���ˬd
if left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6" then
	if left(reg.tfy_arcase.value,3)="FL5" then
	    title_name="���v"
	else
		title_name="�Q���v"
	end if
	if clng(reg.tot_num21.value)<=1 then
		Msgbox title_name & "�ץ�п�J�h��!!!"
		settab 5
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
			answer=msgbox(title_name&"���(�@ "&reg.tot_num21.value&" ��)�P�]�t�D�n�שʿ�J���(�@ "& ctrlcnt &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w��Ʀ@ "& ctrlcnt &" ��H",vbYesNo+vbdefaultbutton2,"�T�{���w���")
			if answer = vbYes then
				execute "reg.tot_num21.value=ctrlcnt"
			else
				settab 5
				execute "reg.tot_num21.focus"
				exit function
			end if
		end if
	end if
	reg.nfy_tot_num.value=reg.tot_num21.value
	for x=1 to reg.nfy_tot_num.value
		if eval("reg.case_stat1b"&x&"(1).checked")=True then
			if eval("reg.keydseqb"&x&".value")="N" then
				msgbox "���ҽs��"&x&"�ܰʹL�A�Ы�[�T�w]���s�A���s������!!!"
				settab 5
				gname="reg.btndseq_okb"&x&".focus"
				execute gname
				exit function
			End IF
		End IF
	next
else
	reg.nfy_tot_num.value=1
end if			
	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false
	reg.tfg1_seq.value = reg.tfzb_seq.value
	reg.tfg1_seq1.value= reg.tfzb_seq1.value	

	reg.action="Brt11AddA7.asp"
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
