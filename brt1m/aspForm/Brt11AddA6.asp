<%
function formAddSubmit()	
'----- �Τ��Submit�e���ˬd�X��b�o�� �A�p�U�� not valid �� exit sub ���}------------ 
    //�Ȥ��p���H�ˬd
    if (main.chkCustAtt() == false) return false;

    //�ӽФH�ˬd
    if (main.chkApp() == false) return false;
	
	if left(reg.tfy_arcase.value,3) = "FC1" or left(reg.tfy_arcase.value,3) = "FC9" or left(reg.tfy_arcase.value,3) = "FC5" or left(reg.tfy_arcase.value,3) = "FC7" or left(reg.tfy_arcase.value,3) = "FCA" or left(reg.tfy_arcase.value,3) = "FCB" or left(reg.tfy_arcase.value,3) = "FCF" or left(reg.tfy_arcase.value,3) = "FCH"  then
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
	
'****���w�ϥΰӫ~/�A�����O�ΦW��
if left(reg.tfy_Arcase.value,3)<>"FC3" then
    //�D�ɰӫ~���O�ˬd
    if (main.chkGood() == false) return false;
else
for u=2 to 2
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
switch ($("#tfy_Arcase").val()) {
	case "FC1": case "FC10": case "FC9": case "FCA": case "FCB":
		'FC1form
		var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_oth", "mod_oth1", "mod_oth2", "mod_claim1"];
		for (var m in arr_mod) {
			if ($("#tfzr_" + arr_mod[m]).prop("checked") == true) {
				$("#tfg1_" + arr_mod[m]).val("Y");
			} else {
				$("#tfg1_" + arr_mod[m]).val("N");
			}
		}
		break;
	case "FC11": case "FC5": case "FC7": case "FCH":
	'FC11form
    var arr_mod = ["mod_ap", "mod_aprep", "mod_agt", "mod_apaddr", "mod_agtaddr", "mod_oth", "mod_oth1", "mod_oth2", "mod_claim1"];
    for (var m in arr_mod) {
        if ($("#tfzr1_" + arr_mod[m]).prop("checked") == true) {
            $("#tfg1_" + arr_mod[m]).val("Y");
        } else {
            $("#tfg1_" + arr_mod[m]).val("N");
        }
    }
	break;
	case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
	'FC2form
	var arr_mod = [ "mod_agt", "mod_oth", "mod_oth1", "mod_dmt","mod_claim1","mod_claim2"];
    for (var m in arr_mod) {
        if ($("#tfop_" + arr_mod[m]).prop("checked") == true) {
            $("#tfg2_" + arr_mod[m]).val("Y");
        } else {
            $("#tfg2_" + arr_mod[m]).val("N");
        }
    }

	if ($("#tfy_Arcase").val()=="FCC"){
		if($("#tfg2_mod_agt").val()=="Y"){
			if($("input[name=tfg2_mod_agttype]:checked").val()!="A"){
				alert("�����U�ƶ��ܧ�(�s�W�N�z�H)�A�N�z�H���ʽ��I��u�s�W�v�I");
				return false;
			}
		}else{
			alert("�����U�ƶ��ܧ�(�s�W�N�z�H)�A�Щ�N�z�H��ƫe�Ŀ�I");
			return false;
		}
	}

	if ($("#tfy_Arcase").val()=="FCD"){
		if($("#tfg2_mod_agt").val()=="Y"){
			if($("input[name=tfg2_mod_agttype]:checked").val()!="D"){
				alert("�����U�ƶ��ܧ�(�M�P�N�z�H)�A�N�z�H���ʽ��I��u�M�P�v�I");
				return false;
			}
		}else{
			alert("�����U�ƶ��ܧ�(�M�P�N�z�H)�A�Щ�N�z�H��ƫe�Ŀ�I");
			return false;
		}
	}
	break;
case "FC21","FC8&","FC6&","FCI&"
	'FC21form
	var arr_mod = [ "mod_agt", "mod_oth", "mod_oth1", "mod_dmt","mod_claim1","mod_claim2"];
    for (var m in arr_mod) {
        if ($("#tfop1_" + arr_mod[m]).prop("checked") == true) {
            $("#tfg2_" + arr_mod[m]).val("Y");
        } else {
            $("#tfg2_" + arr_mod[m]).val("N");
        }
    }
	if($("#tfop1_mod_agttypeC").prop("checked")==true)$("#tfg2_mod_agttypeC").prop("checked",true);
	if($("#tfop1_mod_agttypeA").prop("checked")==true)$("#tfg2_mod_agttypeA").prop("checked",true);
	if($("#tfop1_mod_agttypeD").prop("checked")==true)$("#tfg2_mod_agttypeD").prop("checked",true);
case "FC3&"
	'FC3form
	                if (IsEmpty($("#tft3_class1").val())) {
						$("#tfg3_mod_class").val("N");
					}else{
						$("#tfg3_mod_class").val("Y");
					}
case "FC4&"
end select 

'*****�ץ󤺮e
	select case Left(reg.tfy_arcase.value,4)
		Case "FC1&","FC10","FC9&","FCA&","FCB&","FCF&"
			//�X�W�N�z�H�ˬd(apcust_fc_re1)
    		if (main.chkAgt("FC2_apnum","ttg1_apclass","ttg1_agt_no") == false) return false;

	 		if left(reg.tfy_arcase.value,4) = "FCA&" then
	 		   if trim(reg.FC1_add_agt_no.value)=empty then
	 		      msgbox "���ӽШƶ��ܧ�(�s�W�N�z�H)�A�п�ܷs�W�N�z�H�I"
	 		      settab 7
	 		      reg.FC1_add_agt_no.focus
	 		      exit function
	 		   end if
	 		end if 
		Case "FC11","FC5&","FC7&","FCH&"
			//�X�W�N�z�H�ˬd(apcust_fc_re)
    		if (main.chkAgt("FC2_apnum","ttg1_apclass","ttg11_agt_no") == false) return false;
		Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
			//�X�W�N�z�H�ˬd(apcust_fc_re1)
    		if (main.chkAgt("FC0_apnum","ttg2_apclass","ttg2_agt_no") == false) return false;
		Case "FC21","FC6&","FC8&","FCI&"
			//�X�W�N�z�H�ˬd(apcust_fc_re1)
    		if (main.chkAgt("FC0_apnum","ttg2_apclass","ttg21_agt_no") == false) return false;
		Case "FC3&"
			//�X�W�N�z�H�ˬd(apcust)
    		if (main.chkAgt("apnum","apclass","ttg3_agt_no") == false) return false;
		Case "FC4&"
			//�X�W�N�z�H�ˬd(apcust)
    		if (main.chkAgt("apnum","apclass","ttg4_agt_no") == false) return false;
				
			if reg.fr4_S_Mark(0).checked=true then
				reg.tfzd_Pul.value="2"
				reg.tfzd_S_Mark.value=""
			elseif reg.fr4_S_Mark(1).checked=true then
				reg.tfzd_Pul.value="2"
				reg.tfzd_S_Mark.value="S"
			end if
	End select	

    //���״_���ˬd
    if (main.chkEndBack() == false) return false;
	
	reg.F_tscode.disabled = false
	reg.tfy_case_stat.disabled=false
	reg.tfzd_tcn_mark.disabled = false
	reg.tfgp_seq.value = reg.tfzb_seq.value
	reg.tfgp_seq1.value= reg.tfzb_seq1.value
	
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
					settab 11
						execute "reg.O_item31.focus"
						exit function
					end if
		end if	
End Select	 
 
	reg.action="Brt11AddA6.asp"	
	reg.submitTask.value = "ADD"
	If reg.chkTest.checked=True Then reg.target = "ActFrame" Else reg.target = "_self"
	reg.Submit
End function
</script>
