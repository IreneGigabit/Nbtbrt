<%
function formAddSubmit()	  
'----- 用戶端Submit前的檢查碼放在這裡 ，如下例 not valid 時 exit sub 離開------------ 
    //客戶聯絡人檢查
    if (main.chkCustAtt() == false) return false;
	
    //申請人檢查
    if (main.chkApp() == false) return false;

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

	//出名代理人檢查
    if (main.chkAgt("apnum","apclass","tfzd_agt_no") == false) return false;

    //結案復案檢查
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
	
    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

'指定類別檢查
execute "pname=reg.tfzd_class_count.value"	'抓取指定類別總數
if eval(pname)<>empty then
	'2015/10/21增加檢查商標種類不是M團體標章也不是L證明標章，需點選類別種類及輸入類別
	if reg.tfzd_s_mark.value<>"M" and reg.tfzd_s_mark.value<>"L" then
		if reg.tfzd_class_type(0).checked = false and reg.tfzd_class_type(1).checked = false then
			msgbox "請點選類別種類(國際分類或舊類)！！"
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
						Msgbox "商品類別重覆,請重新輸入!!!"
						settab 5
						execute "reg.class2"&j&".focus"
						exit function
					end if
				end if
				execute "kname=reg.class2"&j&".value"
				if kname<>empty and reg.tfzd_class_type(0).checked then
					if cint(kname) < 0 or cint(kname) > 45 then
						Msgbox "延展類別"&j&"不符國際分類(001~045)。"
						settab 5
						execute "reg.class2"&j&".focus"
						exit function
					end if
				end if
			next
		next	
	end if	
end if	

'***指定類別數目檢查
if reg.tfzd_class_count.value<>empty then
	kname="reg.tfzd_class_count.value"
	gname="reg.ctrlcount2.value"
	class_cnt=eval(kname)
	ctrlcnt=eval(gname)
	    if class_cnt <> ctrlcnt then
			answer=msgbox("指定使用商品類別項目(共 "&eval(kname)&" 類)與輸入指定使用商品(共 "& eval(gname) &" 類)不符，"&chr(13)&chr(13)&"是否確定指定使用商品共 "& eval(gname) &" 類？",vbYesNo+vbdefaultbutton2,"確認商品類別項目")
			if answer = vbYes then
				execute "reg.tfzd_class_count.value=" & ctrlcnt
			else
				settab 5
				execute "reg.tfzd_class_count.focus"
				exit function
			end if
		end if
end if

    //變更項目
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
'附註檢查	
'if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false ) then
'elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true ) then
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false ) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true ) then
	answer=msgbox("附註資料中日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認附註項目")
			if answer <> vbYes then
				settab 5
				execute "reg.O_item1.focus"
				exit function
			end if
end if
'20161006增加備註檢查(因應電子送件修改備註.2欄都可存檔)
if (reg.O_item1.value <> empty or (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true ) ) _
	and reg.O_item(0).checked=false then
	alert("備註項目(1)未勾選，請檢查")
	exit function
end if
if (reg.O_item1.value <> empty or (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true ) ) _
	and reg.O_item(1).checked=false then
	alert("備註項目(2)未勾選，請檢查")
	exit function
end if

'檢查延展商標權範圍及內容
if reg.tfzd_class_count.value<>empty and reg.tfgp_tran_remark2.value<>empty then
	msgbox "延展商品服務名稱、證明標的及內容、表彰組織及會員之會籍只能輸入一項，煩請檢查"
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
