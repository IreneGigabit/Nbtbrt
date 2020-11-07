<%
function formAddSubmit()	
'----- 用戶端Submit前的檢查碼放在這裡 ，如下例 not valid 時 exit sub 離開------------ 
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;

    //申請人檢查
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

    //日期格式檢查,抓class=dateField,有輸入則檢查
    if (main.chkDate("#case") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#dmt") == false) { alert("日期格式有誤,請檢杳"); return false; }
    if (main.chkDate("#tran") == false) { alert("日期格式有誤,請檢杳"); return false; }
	
	//商標名稱檢查
    if (main.chkApplName() == false) return false;

    //必填欄位檢查
    if (main.chkRequire() == false) return false;

    //接洽內容相關檢查
    if (main.chkCaseForm() == false) return false;

    //新/舊案號
    if (main.chkNewOld() == false) return false;

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");

	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value
	
'****指定使用商品/服務類別及名稱
if left(reg.tfy_Arcase.value,3)<>"FC3" then
    //主檔商品類別檢查
    if (main.chkGood() == false) return false;
else
for u=2 to 2
	'類別檢查
	execute "pname=reg.tft3_class_count"&u&".value"	'抓取指定類別總數
	IF eval(pname)<>empty then
		'2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
		if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
			for f=1 to eval(pname)
				execute "gname=reg.class3"&u&f&".value"
				execute "pname=reg.good_name3"&u&f&".value"
				if pname<>empty and gname=empty  then
					msgbox "請輸入類別!!!"
					settab 9
					execute "reg.class3"&u&f&".focus"
					exit function
				end if
				if gname<>empty and reg.tft3_class_type2(0).checked then
					if cint(gname) < 0 or cint(gname) > 45 then
						Msgbox "使用類別"&z&"不符國際分類(001~045)。"
						settab 9
						execute "reg.class3"&u&f&".focus"
						exit function
					end if
	     		end if
			next		
		End IF		
	end if	
	'指定類別檢查
	execute "pname=reg.tft3_class_count"&u&".value"	'抓取指定類別總數
	if pname<>empty then
		'2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
		if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
			for z=1 to pname
				for j=1 to pname
					if z<>j then
						execute "gname=reg.class3"&u&z&".value"
						execute "kname=reg.class3"&u&j&".value"
						if gname<>empty  then
							if gname=kname then
								Msgbox "商品類別重覆,請重新輸入!!!"
								settab 9
								execute "reg.class3"&u&j&".focus"
								exit function
							end if
						end if
					end if
					execute "kname=reg.class3"&u&j&".value"
					if kname<>empty and reg.tft3_class_type2(0).checked then
						if cint(kname) < 0 or cint(kname) > 45 then
							Msgbox "使用類別"&j&"不符國際分類(001~045)。"
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
'***指定類別數目檢查
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
					answer=msgbox("指定件數(共 "&eval(kname)&" 類)與輸入件數(共 "& eval(gname) &" 類)不符，"&chr(13)&chr(13)&"是否確定指定件數共 "& eval(gname) &" 類？",vbYesNo+vbdefaultbutton2,"確認指定件數")
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
			msgbox "有申請權利之讓與，請勾選變更事項！！"
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
			msgbox "有申請權利之讓與，請勾選變更事項！！"
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
				errname="擬減縮"
			case "2"
				errname="減縮後指定"
			end Select
			answer=msgbox(errname&"商品(服務)名稱指定件數(共 "&eval(kname)&" 類)與輸入件數(共 "& eval(gname) &" 類)不符，"&chr(13)&chr(13)&"是否確定指定件數共 "& eval(gname) &" 類？",vbYesNo+vbdefaultbutton2,"確認指定件數")
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

'***變更項目*********************
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
				alert("交辦註冊事項變更(新增代理人)，代理人異動請點選「新增」！");
				return false;
			}
		}else{
			alert("交辦註冊事項變更(新增代理人)，請於代理人資料前勾選！");
			return false;
		}
	}

	if ($("#tfy_Arcase").val()=="FCD"){
		if($("#tfg2_mod_agt").val()=="Y"){
			if($("input[name=tfg2_mod_agttype]:checked").val()!="D"){
				alert("交辦註冊事項變更(撤銷代理人)，代理人異動請點選「撤銷」！");
				return false;
			}
		}else{
			alert("交辦註冊事項變更(撤銷代理人)，請於代理人資料前勾選！");
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

'*****案件內容
	select case Left(reg.tfy_arcase.value,4)
		Case "FC1&","FC10","FC9&","FCA&","FCB&","FCF&"
			//出名代理人檢查(apcust_fc_re1)
    		if (main.chkAgt("FC2_apnum","ttg1_apclass","ttg1_agt_no") == false) return false;

	 		if left(reg.tfy_arcase.value,4) = "FCA&" then
	 		   if trim(reg.FC1_add_agt_no.value)=empty then
	 		      msgbox "交辦申請事項變更(新增代理人)，請選擇新增代理人！"
	 		      settab 7
	 		      reg.FC1_add_agt_no.focus
	 		      exit function
	 		   end if
	 		end if 
		Case "FC11","FC5&","FC7&","FCH&"
			//出名代理人檢查(apcust_fc_re)
    		if (main.chkAgt("FC2_apnum","ttg1_apclass","ttg11_agt_no") == false) return false;
		Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
			//出名代理人檢查(apcust_fc_re1)
    		if (main.chkAgt("FC0_apnum","ttg2_apclass","ttg2_agt_no") == false) return false;
		Case "FC21","FC6&","FC8&","FCI&"
			//出名代理人檢查(apcust_fc_re1)
    		if (main.chkAgt("FC0_apnum","ttg2_apclass","ttg21_agt_no") == false) return false;
		Case "FC3&"
			//出名代理人檢查(apcust)
    		if (main.chkAgt("apnum","apclass","ttg3_agt_no") == false) return false;
		Case "FC4&"
			//出名代理人檢查(apcust)
    		if (main.chkAgt("apnum","apclass","ttg4_agt_no") == false) return false;
				
			if reg.fr4_S_Mark(0).checked=true then
				reg.tfzd_Pul.value="2"
				reg.tfzd_S_Mark.value=""
			elseif reg.fr4_S_Mark(1).checked=true then
				reg.tfzd_Pul.value="2"
				reg.tfzd_S_Mark.value="S"
			end if
	End select	

    //結案復案檢查
    if (main.chkEndBack() == false) return false;
	
	reg.F_tscode.disabled = false
	reg.tfy_case_stat.disabled=false
	reg.tfzd_tcn_mark.disabled = false
	reg.tfgp_seq.value = reg.tfzb_seq.value
	reg.tfgp_seq1.value= reg.tfzb_seq1.value
	
    //檢查大陸案請款註記檢查&給值
    if (main.chkAr() == false) return false;
		
'****總計案性數
	if reg.tfy_arcase.value<>empty then
		reg.nfy_tot_case.value=1
	end if
	for q=1 to 5
		qname="reg.nfyi_item_Arcase"&q&".value"
		if eval(qname)<>empty then
			reg.nfy_tot_case.value=reg.nfy_tot_case.value+1
		end if
	next

'變更一案多件控制	 
Select case left(reg.tfy_arcase.value,4)
	case "FC11","FC5&","FC7&","FCH&"
	IF reg.tot_num11.value=empty and reg.dseqa1.value<>empty  then
		reg.tot_num11.value="1"
	ElseIF reg.tot_num11.value=empty and reg.dseqa2.value<>empty  then
		reg.tot_num11.value="2"
	End IF
	if clng(reg.tot_num11.value)<=1 then
		Msgbox "變更案件請輸入多筆!!!"
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
					answer=msgbox("變更件數(共 "&reg.tot_num11.value&" 件)與包含主要案性輸入件數(共 "& ctrlcnt &" 件)不符，"&chr(13)&chr(13)&"是否確定指定件數共 "& ctrlcnt &" 件？",vbYesNo+vbdefaultbutton2,"確認指定件數")
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
			Msgbox "變更案件請輸入多筆!!!"
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
					answer=msgbox("變更件數(共 "&reg.tot_num21.value&" 件)與包含主要案性輸入件數(共 "& ctrlcnt &" 件)不符，"&chr(13)&chr(13)&"是否確定指定件數共 "& ctrlcnt &" 件？",vbYesNo+vbdefaultbutton2,"確認指定件數")
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
					msgbox "本所編號"&x&"變動過，請按[確定]按鈕，重新抓取資料!!!"
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
					msgbox "本所編號"&x&"變動過，請按[確定]按鈕，重新抓取資料!!!"
					settab 10
					gname="reg.btndseq_okb"&x&".focus"
					execute gname
					exit function
				End IF
			End IF
		next
End Select 	

'附註檢查
Select case left(reg.tfy_arcase.value,4)
	Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
		if reg.O_item21.value = empty and (reg.O_item22(0).checked=false and reg.O_item22(1).checked=false and reg.O_item22(2).checked=false and reg.O_item22(3).checked=false and reg.O_item22(4).checked=false) then
		elseif reg.O_item21.value = empty and (reg.O_item22(0).checked=true or reg.O_item22(1).checked=true or reg.O_item22(2).checked=true or reg.O_item22(3).checked=true or reg.O_item22(4).checked=true) then
			answer=msgbox("附註資料中日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認附註項目")
					if answer <> vbYes then
						settab 9
						execute "reg.O_item21.focus"
						exit function
					end if
		end if
	Case "FC21","FC6&","FC8&"
		if reg.O_item211.value = empty and (reg.O_item221(0).checked=false and reg.O_item221(1).checked=false and reg.O_item221(2).checked=false and reg.O_item221(3).checked=false and reg.O_item221(4).checked=false) then
		elseif reg.O_item211.value = empty and (reg.O_item221(0).checked=true or reg.O_item221(1).checked=true or reg.O_item221(2).checked=true or reg.O_item221(3).checked=true or reg.O_item221(4).checked=true) then
			answer=msgbox("附註資料中日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認附註項目")
					if answer <> vbYes then
						settab 10
						execute "reg.O_item211.focus"
						exit function
					end if
		end if
	Case "FC3&"
		if reg.O_item31.value = empty and (reg.O_item32(0).checked=false and reg.O_item32(1).checked=false and reg.O_item32(2).checked=false and reg.O_item32(3).checked=false and reg.O_item32(4).checked=false) then
		elseif reg.O_item31.value = empty and (reg.O_item32(0).checked=true or reg.O_item32(1).checked=true or reg.O_item32(2).checked=true or reg.O_item32(3).checked=true or reg.O_item32(4).checked=true) then
			answer=msgbox("附註資料中日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認附註項目")
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
