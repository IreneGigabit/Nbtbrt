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

	//�X�W�N�z�H�ˬd
    if (main.chkAgt("apnum","apclass","tfzd_agt_no") == false) return false;

    //���״_���ˬd
    if (main.chkEndBack() == false) return false;

	'reg.tfzd_appl_name.value = reg.tfzd_cappl_name.value
	reg.F_tscode.disabled = false
	reg.tfzd_tcn_mark.disabled = false
	reg.tfgp_seq.value = reg.tfzb_seq.value
	reg.tfgp_seq1.value= reg.tfzb_seq1.value

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");
	
	if reg.tfzy_mark(0).checked=true then
		reg.tfzd_mark.value="N"
	elseif reg.tfzy_mark(1).checked=true then
		reg.tfzd_mark.value="Y"
	end if
	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value
	
    //�D�ɰӫ~���O�ˬd
    if (main.chkGood() == false) return false;

'���w���O�ˬd
execute "pname=reg.tfzd_class_count.value"	'������w���O�`��
if eval(pname)<>empty then
	'2015/10/21�W�[�ˬd�Ӽк������OM����г��]���OL�ҩ��г��A���I�����O�����ο�J���O
	if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
		if reg.tfzd_class_type(0).checked = false and reg.tfzd_class_type(1).checked = false then
			msgbox "���I�����O����(��ڤ���������)�I�I"
			settab 5
			reg.tfzd_class_type(0).focus
			exit function
		end if
		for z=1 to eval(pname)
			for j=1 to eval(pname)
				if z<>j then
					execute "gname=reg.class2"&z&".value"
					execute "kname=reg.class2"&j&".value"
					if gname=kname then
						Msgbox "�ӫ~���O����,�Э��s��J!!!"
						settab 5
						execute "reg.class2"&j&".focus"
						exit function
					end if
				end if
				execute "kname=reg.class2"&j&".value"
				if kname<>empty and reg.tfzd_class_type(0).checked then
					if cint(kname) < 0 or cint(kname) > 45 then
						Msgbox "���i���O"&j&"���Ű�ڤ���(001~045)�C"
						settab 5
						execute "reg.class2"&j&".focus"
						exit function
					end if
				end if
			next
		next	
	end if	
end if	

'***���w���O�ƥ��ˬd
if reg.tfzd_class_count.value<>empty then
	kname="reg.tfzd_class_count.value"
	gname="reg.ctrlcount2.value"
	class_cnt=eval(kname)
	ctrlcnt=eval(gname)
	    if class_cnt <> ctrlcnt then
			answer=msgbox("���w�ϥΰӫ~���O����(�@ "&eval(kname)&" ��)�P��J���w�ϥΰӫ~(�@ "& eval(gname) &" ��)���šA"&chr(13)&chr(13)&"�O�_�T�w���w�ϥΰӫ~�@ "& eval(gname) &" ���H",vbYesNo+vbdefaultbutton2,"�T�{�ӫ~���O����")
			if answer = vbYes then
				execute "reg.tfzd_class_count.value=" & ctrlcnt
			else
				settab 5
				execute "reg.tfzd_class_count.focus"
				exit function
			end if
		end if
end if

    //�ܧ󶵥�
	$("#tfgp_mod_agttype").val($("input[name='tfzr_mod_agttype']:checked").val()||"N");
    var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_pul", "mod_oth", "mod_oth1", "mod_oth2", "mod_dmt"];
    for (var m in arr_mod) {
        if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
            $("#tfgp_" + arr_mod[m]).val("Y");
        } else {
            $("#tfgp_" + arr_mod[m]).val("N");
			if(arr_mod[m]=="mod_agt"){
				$("#tfgp_mod_agttype").val("N");
			}
        }
    }


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
'�����ˬd	
'if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false ) then
'elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true ) then
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false ) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true ) then
	answer=msgbox("������Ƥ��������J�A�T�w�s��?",vbYesNo+vbdefaultbutton2,"�T�{��������")
			if answer <> vbYes then
				settab 5
				execute "reg.O_item1.focus"
				exit function
			end if
end if
'20161006�W�[�Ƶ��ˬd(�]���q�l�e��ק�Ƶ�.2�泣�i�s��)
if (reg.O_item1.value <> empty or (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true ) ) _
	and reg.O_item(0).checked=false then
	alert("�Ƶ�����(1)���Ŀ�A���ˬd")
	exit function
end if
if (reg.O_item1.value <> empty or (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true ) ) _
	and reg.O_item(1).checked=false then
	alert("�Ƶ�����(2)���Ŀ�A���ˬd")
	exit function
end if

'�ˬd���i�Ӽ��v�d��Τ��e
if reg.tfzd_class_count.value<>empty and reg.tfgp_tran_remark2.value<>empty then
	msgbox "���i�ӫ~�A�ȦW�١B�ҩ��Ъ��Τ��e�B�����´�η|�����|�y�u���J�@���A�н��ˬd"
	settab 5
	reg.tfgp_tran_remark2.value=""
	reg.ttr1_RCode(0).checked=false
	reg.ttr1_R1.value=""
	reg.ttr1_RCode(1).checked=false
	reg.ttr1_R9.value=""
	reg.tfzd_class_count.focus
	exit function
end if

if reg.nfy_service.value=0 and reg.nfy_fees.value=0 and reg.tfy_ar_mark.value="N" then
	reg.tfy_ar_code.value="X"
End IF

	reg.action="Brt11AddA4.asp"
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
