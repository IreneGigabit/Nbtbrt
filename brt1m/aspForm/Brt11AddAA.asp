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

'�����ˬd
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false and reg.O_item2(4).checked=false) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true or reg.O_item2(4).checked=true) then
	answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
			if answer <> vbYes then
				settab 5
				execute "reg.O_item1.focus"
				exit function
			end if
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
'*****�ץ󤺮e
if reg.tfgd_mod_claim1(0).checked=false and reg.tfgd_mod_claim1(1).checked=false then
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

	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum","apclass","tfgd_agt_no1") == false) return false;

    //���״_���ˬd
    if (main.chkEndBack() == false) return false;

	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false
    reg.tfgd_seq.value = reg.tfzb_seq.value
	reg.tfgd_seq1.value= reg.tfzb_seq1.value		

	reg.action="Brt11AddAA.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
