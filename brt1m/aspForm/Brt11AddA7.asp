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

	$("#tfzd_color").val($("input[name='tfzy_color']:checked").val()||"");
	$("#tfzd_S_Mark").val($("input[name='tfzy_S_Mark']:checked").val()||"");

	reg.tfzd_pul.value=reg.tfzy_pul.value
	reg.tfzd_zname_type.value=reg.tfzy_zname_type.value
	reg.tfzd_prior_country.value=reg.tfzy_prior_country.value
	reg.tfzd_end_code.value=reg.tfzy_end_code.value
	
    //主檔商品類別檢查
    if (main.chkGood() == false) return false;

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
'*****案件內容
	IF left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6" then
		errName="授權起日"
		errName1="授權迄日"
	Else
		errName="終止日期"
	End If
	If reg.tfg1_term1.value = empty then
	   IF (left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6") then
	       if reg.tfg1_mod_claim1(0).checked=true then
				msgbox errName&"不得為空白,請重新輸入!!"
				settab 5
				reg.tfg1_term1.focus
				exit Function
			end if
		else
			msgbox errName&"不得為空白,請重新輸入!!"
			settab 5
			reg.tfg1_term1.focus
			exit Function
		end if	
	End if
	

IF (left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6") and reg.tfg1_mod_claim1(0).checked=true then
	If reg.tfg1_term2.value = empty then
			msgbox errName1&"不得為空白,請重新輸入!!"
			settab 5
			reg.tfg1_term2.focus
			exit Function
	End if
End if
'點選無截止日種類之檢查
IF (left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6") and reg.tfg1_mod_claim1(1).checked=true then
   if reg.fl_term1.value=empty then
	   msgbox errName&"不得為空白,請重新輸入!!"
	   settab 5
	   reg.fl_term1.focus
	   exit Function
   end if
   reg.tfg1_term1.value=reg.fl_term1.value
end if
If reg.tfzd_mark(0).checked=false and reg.tfzd_mark(1).checked=false then
	msgbox "請輸入申請人!!"
	settab 5
	reg.tfzd_mark(0).focus
	exit function
End If
'附註檢查
'alert (reg.O_item2(5).value)
if reg.O_item1.value = empty and (reg.O_item2(0).checked=false and reg.O_item2(1).checked=false and reg.O_item2(2).checked=false and reg.O_item2(3).checked=false and reg.O_item2(4).checked=false and reg.O_item2(5).checked=false) then
elseif reg.O_item1.value = empty and (reg.O_item2(0).checked=true or reg.O_item2(1).checked=true or reg.O_item2(2).checked=true or reg.O_item2(3).checked=true or reg.O_item2(4).checked=true or reg.O_item2(5).checked=true) then
	answer=msgbox("附註資料中日期未輸入，確定存檔?",vbYesNo+vbdefaultbutton2,"確認附註項目")
			if answer <> vbYes then
				settab 5
				execute "reg.O_item1.focus"
				exit function
			end if
end if
'***授權商品
if left(reg.tfy_arcase.value,3)="FL1" or left(reg.tfy_arcase.value,3)="FL2" or left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6" then
	if reg.tfl1_mod_type(0).checked=false and reg.tfl1_mod_type(1).checked=false then
		msgbox "請選擇授權商品為全部授權或部份授權!!"
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

//出名代理人檢查
if (main.chkAgt("apnum","apclass","tfg1_agt_no1") == false) return false;

    //結案復案檢查
    if (main.chkEndBack() == false) return false;

'授權多件檢查
if left(reg.tfy_arcase.value,3)="FL5" or left(reg.tfy_arcase.value,3)="FL6" then
	if left(reg.tfy_arcase.value,3)="FL5" then
	    title_name="授權"
	else
		title_name="被授權"
	end if
	if clng(reg.tot_num21.value)<=1 then
		Msgbox title_name & "案件請輸入多筆!!!"
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
			answer=msgbox(title_name&"件數(共 "&reg.tot_num21.value&" 件)與包含主要案性輸入件數(共 "& ctrlcnt &" 件)不符，"&chr(13)&chr(13)&"是否確定指定件數共 "& ctrlcnt &" 件？",vbYesNo+vbdefaultbutton2,"確認指定件數")
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
				msgbox "本所編號"&x&"變動過，請按[確定]按鈕，重新抓取資料!!!"
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
