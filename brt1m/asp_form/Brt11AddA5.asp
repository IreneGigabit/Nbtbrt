<% 
Sub doUpdateDB()

'入dmt_temp_log 
call insert_dmt_temp_log(cnn,"U",request("in_scode"),request("in_no")) 
stSQL = "delete from dmt_temp where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and case_sqlno<>0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from case_dmt1 where in_no='"&request("In_no")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'dmt_tran入log
call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
stSQL = "delete from dmt_tran where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & stSQL & "<hr>"
cmd.Execute(stSQL)
'申請人_分割子案
'申請人入log_table
Call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no",trim(request("in_no")))
dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno<>0"
cmd.CommandText=dSQL7
If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & dSQL7 & "<hr>"
cmd.Execute(dSQL7)

update_case_dmt();

update_dmt_temp();

insert_caseitem_dmt();


'商品類別	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then	'2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "12=" & SQL6 & "<hr>"
					cmd.Execute(SQL6)
				END IF
		next
	 End IF	
		
'***新增展覽優先權資料
	
	shownum=request("shownum_dmt")
	if shownum>0 then
	   for i=1 to shownum
	       if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
				isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
				isql=isql & "'" & request("in_no") & "',0," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
				'Response.Write "insert-casedmt_show="&isql&"<br>"
				cmd.CommandText=isql
				If Trim(Request("chkTest"))<>Empty Then Response.Write "13=" & iSQL & "<hr>"
				cmd.Execute(isql)
		   end if		
	   next
	end if	 
	
'*****分割檔	
select case  left(trim(request("tfy_arcase")),3)
  case "FD1"
		if request("O_item11") <>empty or Request("O_item12") <>empty then
			sql = "INSERT INTO dmt_tran("
			sqlValue = ") VALUES("
			sql= sql & "other_item,"
			sqlValue = sqlValue & "'" & Request("O_item11") & ";" & Request("O_item12") & ";" & Request("O_item13") & "'," 	
			SQL=SQL & "in_scode, in_no,tr_date,tr_scode,seq,seq1,"
		    sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & Request("in_no") & "','" & date() & "','" & session("se_scode") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
		    SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
		    'Response.Write SQL3
		    'Response.end
			cmd.CommandText=SQL3
		    If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & SQL3 & "<hr>"
			cmd.Execute(SQL3)
		end if
  Case "FD2","FD3"
		if request("O_item21") <>empty or Request("O_item22") <>empty then
			sql = "INSERT INTO dmt_tran("
			sqlValue = ") VALUES("
			sql= sql & "other_item,"
			sqlValue = sqlValue & "'" & Request("O_item21") & ";" & Request("O_item22") & ";" & Request("O_item23") & "'," 	
			SQL=SQL & "in_scode, in_no,tr_date,tr_scode,seq,seq1,"
		    sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & Request("in_no") & "','" & date() & "','" & session("se_scode") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
		    SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
		   ' Response.Write SQL3
		   ' Response.end
	      cmd.CommandText=SQL3
		  If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL3 & "<hr>"
		  cmd.Execute(SQL3)
		end if
  End Select

'申請人入log_table
	 call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
	 dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=0"
	 cmd.CommandText=dSQL7
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & dSQL7 & "<hr>"
	 cmd.Execute(dSQL7)
	for apnum=1 to trim(request("apnum"))
		ap_cname = replace(trim(request("ap_cname" & apnum)),"'","’")
		if len(ap_cname) > 0 then
			if instr(ap_cname,"&#") > 0 then
			else
			   ap_cname = replace(ap_cname,"&","＆")
			end if
		end if   
		ap_cname1 = replace(trim(request("ap_cname1_" & apnum)),"'","’")
		if len(ap_cname1) > 0 then
			if instr(ap_cname1,"&#") > 0 then
			else
				ap_cname1 = replace(ap_cname1,"&","＆")
			end if
		end if	
		ap_cname2 = replace(trim(request("ap_cname2_" & apnum)),"'","’")
		if len(ap_cname2) > 0 then
			if instr(ap_cname2,"&#") > 0 then
			else
				ap_cname2 = replace(ap_cname2,"&","＆")
			end if
		end if	
		ap_ename = replace(trim(request("ap_ename" & apnum)),"'","’")
		if len(ap_ename) > 0 then
			if instr(ap_ename,"&#") > 0 then
			else
				ap_ename = replace(ap_ename,"&","＆")
			end if
		end if	
		ap_ename1 = replace(trim(request("ap_ename1_" & apnum)),"'","’")
		if len(ap_ename1) > 0 then
			if instr(ap_ename1,"&#") > 0 then
			else
				ap_ename1 = replace(ap_ename1,"&","＆")
			end if
		end if	
		ap_ename2 = replace(trim(request("ap_ename2_" & apnum)),"'","’")
		if len(ap_ename2) > 0 then
			if instr(ap_ename2,"&#") > 0 then
			else
				ap_ename2 = replace(ap_ename2,"&","＆")
			end if
		end if	
		'2009/2/17增加申請人姓及名
		ap_fcname = replace(trim(request("ap_fcname_" & apnum)),"'","’")
		if len(ap_fcname) > 0 then
		   if instr(ap_fcname,"&#") > 0 then
		   else
		      ap_fcname = replace(ap_fcname,"&","＆")
		   end if
		end if
		ap_lcname = replace(trim(request("ap_lcname_" & apnum)),"'","’")
		if len(ap_lcname) > 0 then
		   if instr(ap_lcname,"&#") > 0 then
		   else
		      ap_lcname = replace(ap_lcname,"&","＆")
		   end if
		end if   
		ap_fename = replace(trim(request("ap_fename_" & apnum)),"'","’")
		if len(ap_fename) > 0 then
		   if instr(ap_fename,"&#") > 0 then
		   else
		      ap_fename = replace(ap_fename,"&","＆")
		   end if
		end if
		ap_lename = replace(trim(request("ap_lename_" & apnum)),"'","’")
		if len(ap_lename) > 0 then
		   if instr(ap_lename,"&#") > 0 then
		   else
		      ap_lename = replace(ap_lename,"&","＆")
		   end if
		end if
		SQL7 = "insert into dmt_temp_ap (in_no,case_sqlno,apsqlno,Server_flag,apcust_no,ap_cname,ap_cname1,ap_cname2 "
		SQL7 = SQL7 & ",ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename"
		SQL7 = SQL7 & ",ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4"
		SQL7 = SQL7 & " ) values ("
		SQL7 = SQL7 & "'"& trim(request("in_no")) &"',0,'"& trim(request("apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
		SQL7 = SQL7 & ",'"& trim(request("apcust_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
		SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
		SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
		SQL7 = SQL7 & "," & chkzero(request("ap_sql"&apnum),2) & ",'" & trim(request("ap_zip"&apnum)) & "','" & trim(request("ap_addr1_"&apnum)) & "','" & trim(request("ap_addr2_"&apnum)) & "'"
		SQL7 = SQL7 & ",'" & trim(request("ap_eaddr1_"&apnum)) & "','" & trim(request("ap_eaddr2_"&apnum)) & "','" & trim(request("ap_eaddr3_"&apnum)) & "','" & trim(request("ap_eaddr4_"&apnum)) & "')" 
		'Response.Write "apnum="&SQL7&"<br>"
		'Response.End
		IF SQL7<>empty then
			cmd.CommandText=SQL7
			If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
		End IF
		'Response.Write "apnum="&SQL7&"<br>"
	next
'*****新增文件上傳
	call updmt_attach_forcase(cnn,tprgid,request("in_no"))


IF trim(request("nfy_tot_num"))<>empty then
	for x=1 to trim(request("nfy_tot_num"))

	SQL1 = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1)  "
	SQL2 = "values ('"  & request("in_no") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",") & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
	SQL = sql1 & left(sql2,len(sql2)-1) & ")"
	
	cmd.CommandText=SQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & SQL & "<hr>"
	cmd.Execute(SQL)
	
	SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1"
	Rsreg.open sqlno,cnn,1,1
	Case_sqlno=trim(RSreg("case_sqlno"))
	RSreg.close

			'*****若為新案則新增至案件檔,舊案則不用
		'	If Request("NewOldcase") = "new" then 
					sql = "INSERT INTO dmt_temp("
					sqlValue = ") VALUES("
					IF request("tfzb_seq")<>empty then
						sql=sql&"seq,"
						sqlValue=sqlValue& "'"&request("tfzb_seq")&"',"
					End IF
					IF request("tfzb_seq1")<>empty then
						sql=sql&"seq1,"
						sqlValue=sqlValue& "'"&request("tfzb_seq1")&"',"
					End IF
					IF request("tfzd_S_mark")<>empty then
						sql=sql&"s_mark,"
						sqlValue=sqlValue& "'"&request("tfzd_S_mark")&"',"
					End IF
					IF request("tfzd_pul")<>empty then
						sql=sql&"pul,"
						sqlValue=sqlValue& "'"&request("tfzd_pul")&"',"
					End IF
					IF request("tfzd_Appl_name")<>empty then
						sql=sql&"appl_name,"
						sqlValue=sqlValue& pkstr(request("tfzd_Appl_name"),",")
					End IF
					IF request("tfzd_cappl_name")<>empty then
						sql=sql&"cappl_name,"
						sqlValue=sqlValue& "'"&request("tfzd_cappl_name")&"',"
					End IF
					IF request("tfzd_eappl_name")<>empty then
						sql=sql&"eappl_name,"
						sqlValue=sqlValue& "'"&request("tfzd_eappl_name")&"',"
					End IF
					IF request("tfzd_eappl_name1")<>empty then
						sql=sql&"eappl_name1,"
						sqlValue=sqlValue& "'"&request("tfzd_eappl_name1")&"',"
					End IF
					IF request("tfzd_eappl_name2")<>empty then
						sql=sql&"eappl_name2,"
						sqlValue=sqlValue& "'"&request("tfzd_eappl_name2")&"',"
					End IF
					IF request("tfzd_jappl_name")<>empty then
						sql=sql&"jappl_name,"
						sqlValue=sqlValue& "'"&request("tfzd_jappl_name")&"',"
					End IF
					IF request("tfzd_jappl_name1")<>empty then
						sql=sql&"jappl_name1,"
						sqlValue=sqlValue& "'"&request("tfzd_jappl_name1")&"',"
					End IF
					IF request("tfzd_jappl_name2")<>empty then
						sql=sql&"jappl_name2,"
						sqlValue=sqlValue& "'"&request("tfzd_jappl_name2")&"',"
					End IF
					IF request("tfzd_zappl_name1")<>empty then
						sql=sql&"zappl_name1,"
						sqlValue=sqlValue& "'"&request("tfzd_zappl_name1")&"',"
					End IF
					IF request("tfzd_zappl_name2")<>empty then
						sql=sql&"zappl_name2,"
						sqlValue=sqlValue& "'"&request("tfzd_zappl_name2")&"',"
					End IF
					IF request("tfzd_zname_type")<>empty then
						sql=sql&"zname_type,"
						sqlValue=sqlValue& "'"&request("tfzd_zname_type")&"',"
					End IF
					IF request("tfzd_oappl_name")<>empty then
						sql=sql&"oappl_name,"
						sqlValue=sqlValue& "'"&request("tfzd_oappl_name")&"',"
					End IF
					IF request("tfzd_Draw")<>empty then
						sql=sql&"Draw,"
						sqlValue=sqlValue& "'"&request("tfzd_Draw")&"',"
					End IF
					IF request("tfzd_symbol")<>empty then
						sql=sql&"symbol,"
						sqlValue=sqlValue& "'"&request("tfzd_symbol")&"',"
					End IF
					IF request("tfzd_color")<>empty then
						sql=sql&"color,"
						sqlValue=sqlValue& "'"&request("tfzd_color")&"',"
					End IF
					IF request("tfzd_agt_no")<>empty then
						sql=sql&"agt_no,"
						sqlValue=sqlValue& "'"&request("tfzd_agt_no")&"',"
					End IF
					IF request("pfzd_prior_date")<>empty then
						sql=sql&"prior_date,"
						sqlValue=sqlValue& "'"&request("pfzd_prior_date")&"',"
					End IF
					IF request("tfzd_prior_no")<>empty then
						sql=sql&"prior_no,"
						sqlValue=sqlValue& "'"&request("tfzd_prior_no")&"',"
					End IF
					IF request("tfzd_prior_country")<>empty then
						sql=sql&"prior_country,"
						sqlValue=sqlValue& "'"&request("tfzd_prior_country")&"',"
					End IF
					IF request("tfzd_ref_no")<>empty then
						sql=sql&"ref_no,"
						sqlValue=sqlValue& "'"&request("tfzd_ref_no")&"',"
					End IF
					IF request("tfzd_ref_no1")<>empty then
						sql=sql&"ref_no1,"
						sqlValue=sqlValue& "'"&request("tfzd_ref_no1")&"',"
					End IF
					IF request("tfzb_seq")<>empty then
						sql=sql&"Mseq,"
						sqlValue=sqlValue& "'"&request("tfzb_seq")&"',"
					End IF
					IF request("tfzb_seq1")<>empty then
						sql=sql&"Mseq1,"
						sqlValue=sqlValue& "'"&request("tfzb_seq1")&"',"
					End IF
					'IF request("tfzd_remark1")<>empty then
					'	sql=sql&"remark1,"
					'	sqlValue=sqlValue& "'"&request("tfzd_remark1")&"',"
					'End IF
					'2014/4/15增加寫入申請日，因分割子案申請日與母案相同
					if request("tfzd_apply_date")<>empty then
					   sql=sql&"apply_date,"
					   sqlvalue=sqlvalue&"'" & request("tfzd_apply_date") & "',"
					end if
	Select Case Left(trim(Request("tfy_arcase")),3) 
		Case "FD1"
			if request("FD1_class_count"&x) <> empty then		 
				sql=sql & "class_type,class_count,class,"
				sqlValue = sqlvalue & " '" & request("FD1_class_type"&x) & "','" & Request("FD1_class_count"&x) & "','"&request("FD1_class"&x)&"',"
			end if
			IF request("FD1_Marka"&x)<>empty then
				sql=sql&"mark,"
				sqlValue=sqlValue& "'"&request("FD1_Marka"&x)&"',"
			End IF
			'分割後子案之商標種類2
			s_mark2=""
			select case mid(request("tfy_div_arcase"),3,1)
			case "1","5","H"
				s_mark2="A"
				
			case "4","8","C","G"
				s_mark2="B"
				
			case "3","7","B","F"
				s_mark2="C"
				
			case "2","6","A","E"
				s_mark2="D"
				
			case "I"
				s_mark2="E"
				
			case "J"
				s_mark2="F"
						
			case "K"
				s_mark2="G"
					
			case else
			    s_mark2="A"	
			end select
			if s_mark2<>"" then
			   sql=sql&"s_mark2,"
			   sqlvalue=sqlvalue & "'" & s_mark2 & "',"
			end if
		Case "FD2","FD3"
			if request("FD2_class_count"&x) <> empty then		 
				sql=sql & "class_type,class_count,class,"
				sqlValue = sqlvalue & " '" & request("FD2_class_type"&x) & "','" & Request("FD2_class_count"&x) & "','"&request("FD2_class"&x)&"',"
			end if
			IF request("FD2_Markb"&x)<>empty then
				sql=sql&"mark,"
				sqlValue=sqlValue& "'"&request("FD2_Markb"&x)&"',"
			End IF
			IF request("tfzd_s_mark2")<>empty then
				sql=sql&"s_mark2,"
				sqlValue=sqlValue& "'"&request("tfzd_s_mark2")&"',"
			End IF
	End Select				
			SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,case_sqlno,"
			sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & request("in_no") & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &","
			SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
			
			cmd.CommandText=SQL7
			If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
			
	Select Case Left(trim(Request("tfy_arcase")),3) 
		Case "FD1"	
			ctrlnum=trim(request("FD1_count"&x))
			IF trim(Request("FD1_class_count"&x))<>empty then
				for p=1 to ctrlnum
					if trim(request("classa"&x&p))<>empty or trim(request("FD1_good_namea"&x&p))<>empty then
						SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
						SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','"& case_sqlno &"','"&trim(request("classa"&x&p))&"'"
						SQL6=SQL6&",'"&trim(request("FD1_good_namea"&x&p))&"','"&trim(request("FD1_good_counta"&x&p))&"',"
						SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
					ELSE
						SQL6=""
					end if
					'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "20=" & SQL6 & "<hr>"
							cmd.Execute(SQL6)
						END IF
				next
			 End IF
			 '分割子案展覽優先權入檔
			'分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
			if left(request("tfy_div_arcase"),3)<>"FA9" and left(request("tfy_div_arcase"),3)<>"FAA" and left(request("tfy_div_arcase"),3)<>"FAB" and left(request("tfy_div_arcase"),3)<>"FAC" then
				shownum=request("shownum_dmt")
				if shownum>0 then
					for i=1 to shownum
						if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
							isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
							isql=isql & "'" & request("in_no") & "','" & case_sqlno & "'," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
							'Response.Write "insert-casedmt_show="&isql&"<br>"
							cmd.CommandText=isql
							If Trim(Request("chkTest"))<>Empty Then Response.Write "21=" & iSQL & "<hr>"
							cmd.Execute(isql)
						end if		
					next
				end if	 
			end if	
		Case "FD2","FD3"
			ctrlnum=trim(request("FD2_count"&x))
			IF trim(Request("FD2_class_count"&x))<>empty then
				for p=1 to ctrlnum
					if trim(request("classb"&x&p))<>empty or trim(request("FD2_good_nameb"&x&p))<>empty then
						SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
						SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','"& case_sqlno &"','"&trim(request("classb"&x&p))&"'"
						SQL6=SQL6&",'"&trim(request("FD2_good_nameb"&x&p))&"','"&trim(request("FD2_good_countb"&x&p))&"',"
						SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
					ELSE
						SQL6=""
					end if
					'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "22=" & SQL6 & "<hr>"
							cmd.Execute(SQL6)
						END IF
				next
			 End IF
			 '分割子案展覽優先權入檔
			shownum=request("shownum_dmt")
			if shownum>0 then
				for i=1 to shownum
					if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
						isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
						isql=isql & "'" & request("in_no") & "','" & case_sqlno & "'," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
						'Response.Write "insert-casedmt_show="&isql&"<br>"
						cmd.CommandText=isql
						If Trim(Request("chkTest"))<>Empty Then Response.Write "23=" & iSQL & "<hr>"
						cmd.Execute(isql)
					end if		
				next
			end if	 
	End Select
	
	'申請人_分割子案
			
		for apnum=1 to trim(request("apnum"))
			ap_cname = replace(trim(request("ap_cname" & apnum)),"'","’")
			if len(ap_cname) > 0 then
			if instr(ap_cname,"&#") > 0 then
			else
			   ap_cname = replace(ap_cname,"&","＆")
			end if
		end if   
		ap_cname1 = replace(trim(request("ap_cname1_" & apnum)),"'","’")
		if len(ap_cname1) > 0 then
			if instr(ap_cname1,"&#") > 0 then
			else
				ap_cname1 = replace(ap_cname1,"&","＆")
			end if
		end if	
		ap_cname2 = replace(trim(request("ap_cname2_" & apnum)),"'","’")
		if len(ap_cname2) > 0 then
			if instr(ap_cname2,"&#") > 0 then
			else
				ap_cname2 = replace(ap_cname2,"&","＆")
			end if
		end if	
		ap_ename = replace(trim(request("ap_ename" & apnum)),"'","’")
		if len(ap_ename) > 0 then
			if instr(ap_ename,"&#") > 0 then
			else
				ap_ename = replace(ap_ename,"&","＆")
			end if
		end if	
		ap_ename1 = replace(trim(request("ap_ename1_" & apnum)),"'","’")
		if len(ap_ename1) > 0 then
			if instr(ap_ename1,"&#") > 0 then
			else
				ap_ename1 = replace(ap_ename1,"&","＆")
			end if
		end if	
		ap_ename2 = replace(trim(request("ap_ename2_" & apnum)),"'","’")
		if len(ap_ename2) > 0 then
			if instr(ap_ename2,"&#") > 0 then
			else
				ap_ename2 = replace(ap_ename2,"&","＆")
			end if
		end if	
		'2009/2/17增加申請人姓及名
		ap_fcname = replace(trim(request("ap_fcname_" & apnum)),"'","’")
		if len(ap_fcname) > 0 then
		   if instr(ap_fcname,"&#") > 0 then
		   else
		      ap_fcname = replace(ap_fcname,"&","＆")
		   end if
		end if
		ap_lcname = replace(trim(request("ap_lcname_" & apnum)),"'","’")
		if len(ap_lcname) > 0 then
		   if instr(ap_lcname,"&#") > 0 then
		   else
		      ap_lcname = replace(ap_lcname,"&","＆")
		   end if
		end if   
		ap_fename = replace(trim(request("ap_fename_" & apnum)),"'","’")
		if len(ap_fename) > 0 then
		   if instr(ap_fename,"&#") > 0 then
		   else
		      ap_fename = replace(ap_fename,"&","＆")
		   end if
		end if
		ap_lename = replace(trim(request("ap_lename_" & apnum)),"'","’")
		if len(ap_lename) > 0 then
		   if instr(ap_lename,"&#") > 0 then
		   else
		      ap_lename = replace(ap_lename,"&","＆")
		   end if
		end if
			SQL7 = "insert into dmt_temp_ap (in_no,case_sqlno,apsqlno,Server_flag,apcust_no,ap_cname,ap_cname1,ap_cname2 "
			SQL7 = SQL7 & ",ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename"
			SQL7 = SQL7 & ",ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4"
			SQL7 = SQL7 & " ) values ("
			SQL7 = SQL7 & "'"& trim(request("in_no")) &"','"& Case_sqlno &"','"& trim(request("apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
			SQL7 = SQL7 & ",'"& trim(request("apcust_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
			SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
			SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
			SQL7 = SQL7 & "," & chkzero(request("ap_sql"&apnum),2) & ",'" & trim(request("ap_zip"&apnum)) & "','" & trim(request("ap_addr1_"&apnum)) & "','" & trim(request("ap_addr2_"&apnum)) & "'"
			SQL7 = SQL7 & ",'" & trim(request("ap_eaddr1_"&apnum)) & "','" & trim(request("ap_eaddr2_"&apnum)) & "','" & trim(request("ap_eaddr3_"&apnum)) & "','" & trim(request("ap_eaddr4_"&apnum)) & "')" 
			'Response.Write "apnum="&SQL7&"<br>"
			'Response.End
			IF SQL7<>empty then
				cmd.CommandText=SQL7
				If Trim(Request("chkTest"))<>Empty Then Response.Write "24=" & SQL7 & "<hr>"
				cmd.Execute(SQL7)
			End IF
			'Response.Write "apnum="&SQL7&"<br>"
		next
	next 
End IF
 '後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   cmd.CommandText=SQL4	
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "25=" & SQL4 & "<hr>"
	   cmd.Execute(SQL4)
	End if
	'當程序有修改復案或結案註記時通知營洽人員
	if ucase(prgid)="BRT51" then
	    nback_flag=request("tfy_back_flag")
		if request("tfy_back_flag")=empty then nback_flag="N"
		oback_flag=request("oback_flag")
		if request("oback_flag")=empty then oback_flag="N"
		nend_flag=request("tfy_end_flag")
		if request("tfy_end_flag")=empty then nend_flag="N"
		oend_flag=request("oend_flag")
		if request("oend_flag")=empty then oend_flag="N"
	   	'Response.Write "b1:"&request("oback_flag") & ",b2:"&nback_flag&",e1:"&request("oend_flag") & ",e2:"&nend_flag
	   	'Response.End
	   if trim(nback_flag)<>trim(oback_flag) or trim(nend_flag)<> trim(oend_flag) then
	      Call Sendmail(nback_flag,nend_flag)		        
	      DoSendMail subject,body	
	   end if
	end if
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans  
End sub '---- doUpdateDB() ----


Sub doUpdateDB1(tno,tscode)
dim RTreg
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
Set RTreg = Server.CreateObject("ADODB.Recordset")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	

'商品入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_good","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))   
stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "26=" & stSQL & "<hr>"
cmd.Execute(stSQL)
'展覽優先權入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_show","in_no",trim(request("in_no")))   
stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "27=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'dmt_tran入log
call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 	
stSQL = "delete from dmt_tran where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "28=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'入case_dmt_log
call insert_case_dmt_log(cnn,"U",request("in_scode"),request("in_no"),"brt52國內案交辦維護作業") 

sql = "UPDATE case_dmt SET"
if trim(request("tfy_source"))<>empty then
	SQL = SQL & " source='"&trim(request("tfy_source"))&"',"
End IF
IF trim(request("tfy_contract_no"))<>empty then
	SQL = SQL & " contract_no='"&trim(request("tfy_contract_no"))&"'," 
End IF
IF trim(request("dfy_cust_date"))<>empty then
	SQL = SQL & " cust_date='"&trim(request("dfy_cust_date"))&"',"
End IF
IF trim(request("dfy_pr_date"))<>empty then
	SQL = SQL & " pr_date='"&trim(request("dfy_pr_date"))&"',"
End IF
IF trim(request("tfy_remark")) <> empty then
	SQL = SQL & " remark='"&trim(request("tfy_remark"))&"'," 
End IF
'****結案註記
if request("tfy_end_flag") = empty then
   sql = sql & " end_flag = 'N',end_type='',end_remark='',"
else
   sql = sql & " end_flag = '" & request("tfy_end_flag") & "',end_type='" & request("tfy_end_type") & "',end_remark='" & trim(request("tfy_end_remark")) & "',"   
end if
'****復案註記
if request("tfy_back_flag") = empty then
   sql = sql & " back_flag = 'N',back_remark='',"
else
   sql = sql & " back_flag = '" & request("tfy_back_flag") & "',back_remark='" & trim(request("tfy_back_remark")) & "',"   
end if
'****後續交辦作業序號
if request("grconf_sqlno")<>"" then
   sql = sql & " grconf_sqlno=" & request("grconf_sqlno") & ","
end if
sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
sql = left(sql,len(sql)-1) & sqlWHERE   



  cmd.CommandText=SQL
  If Trim(Request("chkTest"))<>Empty Then Response.Write "29=" & SQL & "<hr>"
  cmd.Execute(SQL)

'****圖檔上傳
	'將檔案更改檔名

	'Set fso = Server.CreateObject("Scripting.FileSystemObject")
	'filepath="/btbrt/" & session("se_branch") & "t/temp"
	filename = Request.Form("in_no")
	aa=request("draw_file")
	oldfilename=request("file")
	newfilename=""
	if aa = oldfilename then
		newfilename=oldfilename
	else
		if Instr(1,aa,"temp") > 0 then
			aa = mid(aa,Instr(1,aa,"temp")+5)
		end if
		if aa <> "" then
			'2013/11/26修改可以中文檔名上傳及虛擬路徑
			strpath="/btbrt/" & session("se_branch") & "T/temp"
			attach_name = filename & "." & right(aa,len(aa)-InstrRev(aa,"."))	'重新命名檔名
			newfilename = strpath & "/" & attach_name	'存在資料庫路徑
			call renameFile_nobackup(strpath,aa,attach_name)
		end if   
	end if
	
		'入dmt_temp_log 
		call insert_dmt_temp_log(cnn,"U",request("in_scode"),request("in_no")) 
		
		sql = "UPDATE dmt_temp SET "   
		sqlWhere = ""
		for each x in request.form
	     if mid(x,2,3) = "fzd" or mid(x,2,3) = "fzp" then					
	    			select case left(x,1)		       
						 case "d"
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
						 case "n"
							 sql = sql & " " & mid(x,6) & "=" & drn(x)
						 case else
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
					 end select
	     end if
		next
		sql = sql & " draw_file = " & pkstr(newfilename,",") & _
					" tr_date  = '" & date() & "'," & _
			        " tr_scode = '" & session("se_scode") & "',"& _
			        " class = '" & request("tfzr_class") & "',"& _
					" class_count = '" & request("tfzr_class_count") & "',"
		SQL=  sql & "in_scode = '" & request("F_tscode") & "',"			        
		sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "' and case_sqlno=0" 
		sql = left(sql,len(sql)-1) & sqlWHERE  
'Response.Write SQL
		cmd.CommandText=SQL
		If Trim(Request("chkTest"))<>Empty Then Response.Write "30=" & SQL & "<hr>"
		cmd.Execute(SQL)
'Response.End
'商品類別	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "31=" & SQL6 & "<hr>"
					cmd.Execute(SQL6)
				END IF
		next
	 End IF	

'***新增展覽優先權資料
	
	shownum=request("shownum_dmt")
	if shownum>0 then
	   for i=1 to shownum
	       if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
				isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
				isql=isql & "'" & request("in_no") & "',0," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
				'Response.Write "insert-casedmt_show="&isql&"<br>"
				cmd.CommandText=isql
				If Trim(Request("chkTest"))<>Empty Then Response.Write "32=" & iSQL & "<hr>"
				cmd.Execute(isql)
		   end if		
	   next
	end if	 		

'*****移轉檔	
select case  left(trim(request("tfy_arcase")),3)
  case "FD1"
		if request("O_item11") <>empty or Request("O_item12") <>empty then
			sql = "INSERT INTO dmt_tran("
			sqlValue = ") VALUES("
			sql= sql & "other_item,"
			sqlValue = sqlValue & "'" & Request("O_item11") & ";" & Request("O_item12") & ";" & Request("O_item13") & "'," 	
			SQL=SQL & "in_scode, in_no,tr_date,tr_scode,seq,seq1,"
		    sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & Request("in_no") & "','" & date() & "','" & session("se_scode") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
		    SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
		    'Response.Write SQL3
		    'Response.end
			cmd.CommandText=SQL3
		    If Trim(Request("chkTest"))<>Empty Then Response.Write "33=" & SQL3 & "<hr>"
			cmd.Execute(SQL3)
		end if
  Case "FD2","FD3"
		if request("O_item21") <>empty or Request("O_item22") <>empty then
			sql = "INSERT INTO dmt_tran("
			sqlValue = ") VALUES("
			sql= sql & "other_item,"
			sqlValue = sqlValue & "'" & Request("O_item21") & ";" & Request("O_item22") & ";" & Request("O_item23") & "'," 	
			SQL=SQL & "in_scode, in_no,tr_date,tr_scode,seq,seq1,"
		    sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & Request("in_no") & "','" & date() & "','" & session("se_scode") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
		    SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
		   ' Response.Write SQL3
		   ' Response.end
	      cmd.CommandText=SQL3
		  If Trim(Request("chkTest"))<>Empty Then Response.Write "34=" & SQL3 & "<hr>"
		  cmd.Execute(SQL3)
		end if
  End Select
	
	'申請人入log_table
	 call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
	 dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=0"
	 cmd.CommandText=dSQL7
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "35=" & dSQL7 & "<hr>"
	 cmd.Execute(dSQL7)
	for apnum=1 to trim(request("apnum"))
		ap_cname = replace(trim(request("ap_cname" & apnum)),"'","’")
		if len(ap_cname) > 0 then
			if instr(ap_cname,"&#") > 0 then
			else
			   ap_cname = replace(ap_cname,"&","＆")
			end if
		end if   
		ap_cname1 = replace(trim(request("ap_cname1_" & apnum)),"'","’")
		if len(ap_cname1) > 0 then
			if instr(ap_cname1,"&#") > 0 then
			else
				ap_cname1 = replace(ap_cname1,"&","＆")
			end if
		end if	
		ap_cname2 = replace(trim(request("ap_cname2_" & apnum)),"'","’")
		if len(ap_cname2) > 0 then
			if instr(ap_cname2,"&#") > 0 then
			else
				ap_cname2 = replace(ap_cname2,"&","＆")
			end if
		end if	
		ap_ename = replace(trim(request("ap_ename" & apnum)),"'","’")
		if len(ap_ename) > 0 then
			if instr(ap_ename,"&#") > 0 then
			else
				ap_ename = replace(ap_ename,"&","＆")
			end if
		end if	
		ap_ename1 = replace(trim(request("ap_ename1_" & apnum)),"'","’")
		if len(ap_ename1) > 0 then
			if instr(ap_ename1,"&#") > 0 then
			else
				ap_ename1 = replace(ap_ename1,"&","＆")
			end if
		end if	
		ap_ename2 = replace(trim(request("ap_ename2_" & apnum)),"'","’")
		if len(ap_ename2) > 0 then
			if instr(ap_ename2,"&#") > 0 then
			else
				ap_ename2 = replace(ap_ename2,"&","＆")
			end if
		end if	
		'2009/2/17增加申請人姓及名
		ap_fcname = replace(trim(request("ap_fcname_" & apnum)),"'","’")
		if len(ap_fcname) > 0 then
		   if instr(ap_fcname,"&#") > 0 then
		   else
		      ap_fcname = replace(ap_fcname,"&","＆")
		   end if
		end if
		ap_lcname = replace(trim(request("ap_lcname_" & apnum)),"'","’")
		if len(ap_lcname) > 0 then
		   if instr(ap_lcname,"&#") > 0 then
		   else
		      ap_lcname = replace(ap_lcname,"&","＆")
		   end if
		end if   
		ap_fename = replace(trim(request("ap_fename_" & apnum)),"'","’")
		if len(ap_fename) > 0 then
		   if instr(ap_fename,"&#") > 0 then
		   else
		      ap_fename = replace(ap_fename,"&","＆")
		   end if
		end if
		ap_lename = replace(trim(request("ap_lename_" & apnum)),"'","’")
		if len(ap_lename) > 0 then
		   if instr(ap_lename,"&#") > 0 then
		   else
		      ap_lename = replace(ap_lename,"&","＆")
		   end if
		end if
		SQL7 = "insert into dmt_temp_ap (in_no,case_sqlno,apsqlno,Server_flag,apcust_no,ap_cname,ap_cname1,ap_cname2 "
		SQL7 = SQL7 & ",ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename"
		SQL7 = SQL7 & ",ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4"
		SQL7 = SQL7 & " ) values ("
		SQL7 = SQL7 & "'"& trim(request("in_no")) &"',0,'"& trim(request("apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
		SQL7 = SQL7 & ",'"& trim(request("apcust_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
		SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
		SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
		SQL7 = SQL7 & "," & chkzero(request("ap_sql"&apnum),2) & ",'" & trim(request("ap_zip"&apnum)) & "','" & trim(request("ap_addr1_"&apnum)) & "','" & trim(request("ap_addr2_"&apnum)) & "'"
		SQL7 = SQL7 & ",'" & trim(request("ap_eaddr1_"&apnum)) & "','" & trim(request("ap_eaddr2_"&apnum)) & "','" & trim(request("ap_eaddr3_"&apnum)) & "','" & trim(request("ap_eaddr4_"&apnum)) & "')"
		
		'Response.Write "apnum="&SQL7&"<br>"
		'Response.End
		IF SQL7<>empty then
			cmd.CommandText=SQL7
			If Trim(Request("chkTest"))<>Empty Then Response.Write "36=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
		End IF
		'Response.Write "apnum="&SQL7&"<br>"
	next
	'文件上傳
	call updmt_attach_forcase(cnn,tprgid,request("in_no"))
	
'申請人入log_table
Call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no",trim(request("in_no")))
dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno<>0"
cmd.CommandText=dSQL7
If Trim(Request("chkTest"))<>Empty Then Response.Write "37=" & dSQL7 & "<hr>"
cmd.Execute(dSQL7)	
IF trim(request("nfy_tot_num"))<>empty then
	for x=1 to trim(request("nfy_tot_num"))
		sql = "UPDATE dmt_temp SET "   
		sqlWhere = ""
		sql=sql&"s_mark="&chknull(request("tfzd_S_mark"))&","
		sql=sql&"pul="&chknull(request("tfzd_pul"))&","
		sql=sql&"appl_name="&chknull(request("tfzd_Appl_name"))&","
		sql=sql&"cappl_name="&chknull(request("tfzd_cappl_name"))&","
		sql=sql&"eappl_name="&chknull(request("tfzd_eappl_name"))&","
		sql=sql&"eappl_name1="&chknull(request("tfzd_eappl_name1"))&","
		sql=sql&"eappl_name2="&chknull(request("tfzd_eappl_name2"))&","
		sql=sql&"jappl_name="&chknull(request("tfzd_jappl_name"))&","
		sql=sql&"jappl_name1="&chknull(request("tfzd_jappl_name1"))&","
		sql=sql&"jappl_name2="&chknull(request("tfzd_jappl_name2"))&","
		sql=sql&"zappl_name1="&chknull(request("tfzd_zappl_name1"))&","
		sql=sql&"zappl_name2="&chknull(request("tfzd_zappl_name2"))&","
		sql=sql&"zname_type="&chknull(request("tfzd_zname_type"))&","
		sql=sql&"oappl_name="&chknull(request("tfzd_oappl_name"))&","
		sql=sql&"Draw="&chknull(request("tfzd_Draw"))&","
		sql=sql&"symbol="&chknull(request("tfzd_symbol"))&","
		sql=sql&"color="&chknull(request("tfzd_color"))&","
		sql=sql&"agt_no="&chknull(request("tfzd_agt_no"))&","
		sql=sql&"prior_date="&chknull(request("pfzd_prior_date"))&","
		sql=sql&"prior_no="&chknull(request("tfzd_prior_no"))&","
		sql=sql&"prior_country="&chknull(request("tfzd_prior_country"))&","
		sql=sql&"ref_no="&chknull(request("tfzd_ref_no"))&","
		sql=sql&"ref_no1="&chknull(request("tfzd_ref_no1"))&","
		sql=sql&"apply_date="&chknull(request("tfzd_apply_date"))&"," '2014/4/15增加寫入申請日，因分割子案申請日與母案相同
		Select Case Left(trim(Request("tfy_arcase")),3) 
		Case "FD1"
				sql=sql & "class_count=" & chknull(Request("FD1_class_count"&x)) &","
				sql=sql & "class="&chknull(request("FD1_class"&x))&","
				sql=sql & "class_type=" & chknull(request("FD1_class_type"&x)) & ","
				sql=sql & "mark="&chknull(request("FD1_Marka"&x))&","
				'分割後子案之商標種類2
				s_mark2=""
				select case mid(request("tfy_div_arcase"),3,1)
					case "1","5","H"
						s_mark2="A"
					case "4","8","C","G"
						s_mark2="B"
					case "3","7","B","F"
						s_mark2="C"
					case "2","6","A","E"
						s_mark2="D"
					case "I"
						s_mark2="E"
					case "J"
						s_mark2="F"
					case "K"
						s_mark2="G"
					case else
						s_mark2="A"	
				end select
				sql=sql & "s_mark2=" & chknull(s_mark2) & ","
		Case "FD2","FD3"
			sql=sql & "class_count=" & chknull(Request("FD2_class_count"&x)) &","
			sql=sql & "class="&chknull(request("FD2_class"&x))&","
			sql=sql & "class_type=" & chknull(request("FD2_class_count"&x)) & ","
			sql=sql & "mark="&chknull(request("FD2_Markb"&x))&","
			sql=sql & "s_mark2=" & chknull(request("tfzd_s_mark2"))&","
		End Select				
			SQL=SQL & "tr_date='" & date() & "',tr_scode='" & session("se_scode") & "',"
			sqlWhere = " where in_scode='" & Request("in_scode") & "' and in_no='" & request("in_no") & "'"
		Select Case Left(trim(Request("tfy_arcase")),3) 
		Case "FD1"
			sqlWhere = sqlWhere & " and case_sqlno='"&trim(request("FD1_case_sqlno"&x))&"'"
		Case "FD2","FD3"
			sqlWhere = sqlWhere & " and case_sqlno='"&trim(request("FD2_case_sqlno"&x))&"'"
		End Select
			SQL7 = left(sql,len(sql)-1)& sqlWHERE
			'Response.Write SQL7&"<br><br>"
			'response.end
			cmd.CommandText=SQL7
			If Trim(Request("chkTest"))<>Empty Then Response.Write "38=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)

	Select Case Left(trim(Request("tfy_arcase")),3) 
		Case "FD1"	
			ctrlnum=trim(request("FD1_count"&x))
			IF trim(Request("FD1_class_count"&x))<>empty then
				for p=1 to ctrlnum
					if trim(request("classa"&x&p))<>empty or trim(request("FD1_good_namea"&x&p))<>empty then
						SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
						SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','"& trim(request("FD1_case_sqlno"&x)) &"','"&trim(request("classa"&x&p))&"'"
						SQL6=SQL6&",'"&trim(request("FD1_good_namea"&x&p))&"','"&trim(request("FD1_good_counta"&x&p))&"',"
						SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
					ELSE
						SQL6=""
					end if
					'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "39=" & SQL6 & "<hr>"
							cmd.Execute(SQL6)
						END IF
				next
			 End IF
			  '分割子案展覽優先權入檔
			'分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
			if left(request("tfy_div_arcase"),3)<>"FA9" and left(request("tfy_div_arcase"),3)<>"FAA" and left(request("tfy_div_arcase"),3)<>"FAB" and left(request("tfy_div_arcase"),3)<>"FAC" then
				shownum=request("shownum_dmt")
				if shownum>0 then
					for i=1 to shownum
						if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
							isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
							isql=isql & "'" & request("in_no") & "','" & trim(request("FD1_case_sqlno"&x)) & "'," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
							'Response.Write "insert-casedmt_show="&isql&"<br>"
							cmd.CommandText=isql
							If Trim(Request("chkTest"))<>Empty Then Response.Write "40=" & iSQL & "<hr>"
							cmd.Execute(isql)
						end if		
					next
				end if	 
			end if	
		Case "FD2","FD3"
			ctrlnum=trim(request("FD2_count"&x))
			IF trim(Request("FD2_class_count"&x))<>empty then
				for p=1 to ctrlnum
					if trim(request("classb"&x&p))<>empty or trim(request("FD2_good_nameb"&x&p))<>empty then
						SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
						SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','"& trim(request("FD2_case_sqlno"&x)) &"','"&trim(request("classb"&x&p))&"'"
						SQL6=SQL6&",'"&trim(request("FD2_good_nameb"&x&p))&"','"&trim(request("FD2_good_countb"&x&p))&"',"
						SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
					ELSE
						SQL6=""
					end if
					'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "41=" & SQL6 & "<hr>"
							cmd.Execute(SQL6)
						END IF
				next
			 End IF
			   '分割子案展覽優先權入檔
				shownum=request("shownum_dmt")
				if shownum>0 then
					for i=1 to shownum
						if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
							isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
							isql=isql & "'" & request("in_no") & "','" & trim(request("FD2_case_sqlno"&x)) & "'," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
							'Response.Write "insert-casedmt_show="&isql&"<br>"
							cmd.CommandText=isql
							If Trim(Request("chkTest"))<>Empty Then Response.Write "42=" & iSQL & "<hr>"
							cmd.Execute(isql)
						end if		
					next
				end if	 
				
	End Select
	'申請人_分割子案
		for apnum=1 to trim(request("apnum"))
			ap_cname = replace(trim(request("ap_cname" & apnum)),"'","’")
			if len(ap_cname) > 0 then
			if instr(ap_cname,"&#") > 0 then
			else
			   ap_cname = replace(ap_cname,"&","＆")
			end if
		end if   
		ap_cname1 = replace(trim(request("ap_cname1_" & apnum)),"'","’")
		if len(ap_cname1) > 0 then
			if instr(ap_cname1,"&#") > 0 then
			else
				ap_cname1 = replace(ap_cname1,"&","＆")
			end if
		end if	
		ap_cname2 = replace(trim(request("ap_cname2_" & apnum)),"'","’")
		if len(ap_cname2) > 0 then
			if instr(ap_cname2,"&#") > 0 then
			else
				ap_cname2 = replace(ap_cname2,"&","＆")
			end if
		end if	
		ap_ename = replace(trim(request("ap_ename" & apnum)),"'","’")
		if len(ap_ename) > 0 then
			if instr(ap_ename,"&#") > 0 then
			else
				ap_ename = replace(ap_ename,"&","＆")
			end if
		end if	
		ap_ename1 = replace(trim(request("ap_ename1_" & apnum)),"'","’")
		if len(ap_ename1) > 0 then
			if instr(ap_ename1,"&#") > 0 then
			else
				ap_ename1 = replace(ap_ename1,"&","＆")
			end if
		end if	
		ap_ename2 = replace(trim(request("ap_ename2_" & apnum)),"'","’")
		if len(ap_ename2) > 0 then
			if instr(ap_ename2,"&#") > 0 then
			else
				ap_ename2 = replace(ap_ename2,"&","＆")
			end if
		end if	
		'2009/2/17增加申請人姓及名
		ap_fcname = replace(trim(request("ap_fcname_" & apnum)),"'","’")
		if len(ap_fcname) > 0 then
		   if instr(ap_fcname,"&#") > 0 then
		   else
		      ap_fcname = replace(ap_fcname,"&","＆")
		   end if
		end if
		ap_lcname = replace(trim(request("ap_lcname_" & apnum)),"'","’")
		if len(ap_lcname) > 0 then
		   if instr(ap_lcname,"&#") > 0 then
		   else
		      ap_lcname = replace(ap_lcname,"&","＆")
		   end if
		end if   
		ap_fename = replace(trim(request("ap_fename_" & apnum)),"'","’")
		if len(ap_fename) > 0 then
		   if instr(ap_fename,"&#") > 0 then
		   else
		      ap_fename = replace(ap_fename,"&","＆")
		   end if
		end if
		ap_lename = replace(trim(request("ap_lename_" & apnum)),"'","’")
		if len(ap_lename) > 0 then
		   if instr(ap_lename,"&#") > 0 then
		   else
		      ap_lename = replace(ap_lename,"&","＆")
		   end if
		end if
			SQL7 = "insert into dmt_temp_ap (in_no,case_sqlno,apsqlno,Server_flag,apcust_no,ap_cname,ap_cname1,ap_cname2 "
			SQL7 = SQL7 & ",ap_ename,ap_ename1,ap_ename2,tran_date,tran_scode,ap_fcname,ap_lcname,ap_fename,ap_lename"
			SQL7 = SQL7 & ",ap_sql,ap_zip,ap_addr1,ap_addr2,ap_eaddr1,ap_eaddr2,ap_eaddr3,ap_eaddr4"
			SQL7 = SQL7 & " ) values ("
			SQL7 = SQL7 & "'"& trim(request("in_no")) &"','"& Case_sqlno &"','"& trim(request("apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
			SQL7 = SQL7 & ",'"& trim(request("apcust_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
			SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
			SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
			SQL7 = SQL7 & "," & chkzero(request("ap_sql"&apnum),2) & ",'" & trim(request("ap_zip"&apnum)) & "','" & trim(request("ap_addr1_"&apnum)) & "','" & trim(request("ap_addr2_"&apnum)) & "'"
		    SQL7 = SQL7 & ",'" & trim(request("ap_eaddr1_"&apnum)) & "','" & trim(request("ap_eaddr2_"&apnum)) & "','" & trim(request("ap_eaddr3_"&apnum)) & "','" & trim(request("ap_eaddr4_"&apnum)) & "')"
			'Response.Write "apnum="&SQL7&"<br>"
			'Response.End
			IF SQL7<>empty then
				cmd.CommandText=SQL7
				If Trim(Request("chkTest"))<>Empty Then Response.Write "43=" & SQL7 & "<hr>"
				cmd.Execute(SQL7)
			End IF
			'Response.Write "apnum="&SQL7&"<br>"
		next
next 
End IF
	'後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   cmd.CommandText=SQL4	
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "44=" & SQL4 & "<hr>"
	   cmd.Execute(SQL4)
	End if
	'Response.End
  SQL="select max(sqlno) as Msqlno from ToDoList where in_no = '" & tno & "' and in_scode = '" & tscode & "' and apcode='Si04W02' and dowhat='DC'"
   RTreg.Open sql,connsys,1,1,adcmdtext
   sqlno=RTreg("Msqlno")
   RTreg.close
   sql1="select * from todolist where sqlno = " & sqlno
   RTreg.Open sql1,connsys,1,1,adcmdtext
   if not RTreg.EOF then				
   			
		SQLins="Insert into ToDoList (pre_sqlno,Branch,Syscode,Apcode,In_team,In_scode,In_no,Case_no,Step_date,dowhat,Job_scode,Job_status,mark) " & _
		       " values ('" & Mscode & "','" & RTreg("Branch") & "','" & RTreg("Syscode") & "','" & RTreg("Apcode") & "', '" & _
				RTreg("In_team") & "','" & RTreg("In_scode") & "','" & RTreg("In_no") & "','" & RTreg("Case_no") & "','" & _
				date() & "','DP','" & RTreg("job_scode") & "','NN'," &  pkstr(Request.Form("Mark"),")")
	    'Response.Write sqlins		
										
			
		sql=sqlins
		If Trim(Request("chkTest"))<>Empty Then Response.Write "45=" & SQL & "<hr>"
		connsys.execute(sql) 	
  end if
  RTreg.close	 
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans  
End sub '---- doUpdateDB1() ----%>

