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

if left(reg.tfy_arcase.value,3)="FP1" then
	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;

	reg.tfg1_seq.value = reg.tfzb_seq.value
	reg.tfg1_seq1.value= reg.tfzb_seq1.value	
elseif left(reg.tfy_arcase.value,3)="FP2" then
	//�X�W�N�z�H�ˬd
	if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;

	reg.tfg2_seq.value = reg.tfzb_seq.value
	reg.tfg2_seq1.value= reg.tfzb_seq1.value	
End iF

    //���״_���ˬd
    if (main.chkEndBack() == false) return false;

	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false

	reg.action="Brt11AddA9.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
