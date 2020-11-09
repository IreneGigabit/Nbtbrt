<%
Sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	
	
'******************產生流水號

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"

	sql = "INSERT INTO case_dmt("


	'將檔案更改檔名
	aa=request("draw_file")
	if trim(request("tfy_case_stat"))<>"OO"  then
		if trim(aa) <> empty then
			'IF ubound(split(trim(request("draw_file")),"\"))=0 then
			IF ubound(split(trim(request("draw_file")),"/"))=0 then
				'filesource = server.MapPath(filepath) & "\" & aa 'temp
				'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
				'fso.MoveFile filesource,newfilename
				'aa=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
				'2013/11/26修改可以中文檔名上傳及虛擬路徑
				strpath="/btbrt/" & session("se_branch") & "T/temp"
				attach_name = RSno & "." & right(aa,len(aa)-InstrRev(aa,"."))	'重新命名檔名
				newfilename = strpath & "/" & attach_name	'存在資料庫路徑
				call renameFile_nobackup(strpath,aa,attach_name)
			else
				newfilename = trim(request("draw_file"))
			End IF
		else
			newfilename = ""
		end if
	else
		'IF ubound(split(trim(request("draw_file")),"\"))=0 then
		IF ubound(split(trim(request("draw_file")),"/"))=0 then
			aa=trim(request("draw_file"))
			if trim(aa) <> empty then
				'filesource = server.MapPath(filepath) & "\" & aa 'temp
				'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
				'fso.MoveFile filesource,newfilename
				'aa=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
				'2013/11/26修改可以中文檔名上傳及虛擬路徑
				strpath="/btbrt/" & session("se_branch") & "T/temp"
				attach_name = RSno & "." & right(aa,len(aa)-InstrRev(aa,"."))	'重新命名檔名
				newfilename = strpath & "/" & attach_name	'存在資料庫路徑
				call renameFile_nobackup(strpath,aa,attach_name)
			else
				newfilename = ""
			end if
		else
			newfilename = trim(request("draw_file"))
		End IF
	end if
			sql = "INSERT INTO dmt_temp("
			sqlValue = ") VALUES("
			for each x in request.form
				if request(x) <> "" then
					if mid(x,2,4) = "fzd_" or mid(x,2,3) = "fzb" or mid(x,2,3) = "fzp" then
						select case left(x,1)
							case "p"
								sql = sql & mid(x,6) & ","
								sqlValue = sqlValue & pkStr(request(x),",")
							case "d"
								sql = sql & mid(x,6) & ","
								sqlValue = sqlValue & pkdate(request(x),",")
							case "n"
								sql = sql & mid(x,6) & ","
								sqlValue = sqlValue & request(x) & ","
							case else
								sql = sql & mid(x,6) & ","
								sqlValue = sqlValue & pkStr(request(x),",")
						end select
					end if
				end if
			next
			
			if request("tfzr_class_count") <> empty then		 
				sql=sql & "class_type,class_count,class,"
				sqlValue = sqlvalue & " '" & request("tfzr_class_type") & "','" & Request("tfzr_class_count") & "','"&request("tfzr_class")&"',"
			end if
			
			SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,case_sqlno,Mseq1,Mseq,"
			sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',0," & pkstr(request("tfzb_seq1"),",") & pkstr(request("tfzb_seq"),",")
				  
			SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
						
			cmd.CommandText=SQL3
			If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & SQL3 & "<hr>"
			cmd.Execute(SQL3)	

'****次委辦案性			
	sql5 = "INSERT INTO caseitem_dmt (in_scode,in_no,item_sql,seq,seq1,item_arcase,item_service,item_fees,item_count) values"

select case  left(trim(request("tfy_arcase")),3)
  case "FD1"
		if request("O_item11") <>empty or Request("O_item12") <>empty then
			sql = "INSERT INTO dmt_tran("
			sqlValue = ") VALUES("
			sql= sql & "other_item,"
			sqlValue = sqlValue & "'" & Request("O_item11") & ";" & Request("O_item12") & ";" & Request("O_item13") & "'," 	
			SQL=SQL & "in_scode, in_no,tr_date,tr_scode,seq,seq1,"
		    sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & session("se_scode") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
		    SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
		    'Response.Write SQL3
		    'Response.end
			cmd.CommandText=SQL3
		    If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & SQL3 & "<hr>"
			cmd.Execute(SQL3)
		end if
  Case "FD2","FD3"
		if request("O_item21") <>empty or Request("O_item22") <>empty then
			sql = "INSERT INTO dmt_tran("
			sqlValue = ") VALUES("
			sql= sql & "other_item,"
			sqlValue = sqlValue & "'" & Request("O_item21") & ";" & Request("O_item22") & ";" & Request("O_item23") & "'," 	
			SQL=SQL & "in_scode, in_no,tr_date,tr_scode,seq,seq1,"
		    sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & session("se_scode") & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
		    SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
		   ' Response.Write SQL3
		   ' Response.end
	      cmd.CommandText=SQL3
		  If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & SQL3 & "<hr>"
		  cmd.Execute(SQL3)
		end if
  End Select
  
  'Response.End
  
'商品類別	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then	'2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & RSno & "','"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			IF SQL6<>EMPTY THEN
				cmd.CommandText=SQL6
				If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & SQL6 & "<hr>"
				cmd.Execute(SQL6)
			END IF
		next
	 End IF

            //****新增展覽優先權資料
            insert_casedmt_show(conn, RSno);

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

IF trim(request("nfy_tot_num"))<>empty then
	for x=1 to trim(request("nfy_tot_num"))
	'cnn.BeginTrans
	SQL1 = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1)  "
	SQL2 = "values ('"  & RSno & "'," & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",") & pkstr(request("tfzb_seq"),",") & pkstr(request("tfzb_seq1"),",")
	SQL = sql1 & left(sql2,len(sql2)-1) & ")"
	
	cmd.CommandText=SQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "11=" & SQL & "<hr>"
	cmd.Execute(SQL)
	'cnn.CommitTrans
	'cnn.BeginTrans	
	
	SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1 "
	'Set RSreg = Conn.execute(SQLno)	
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
				sqlValue = sqlvalue & "'" & request("FD2_class_type"&x) & "','" & Request("FD2_class_count"&x) & "','"&request("FD2_class"&x)&"',"
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
			sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &","
			SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
			'Response.Write sql7&"<br>"
			'Response.End
			cmd.CommandText=SQL7
			
			If Trim(Request("chkTest"))<>Empty Then Response.Write "12=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)

'Response.End

	Select Case Left(trim(Request("tfy_arcase")),3) 
		Case "FD1"	
			ctrlnum=trim(request("FD1_count"&x))
			IF trim(Request("FD1_class_count"&x))<>empty then
				for p=1 to ctrlnum
					if trim(request("classa"&x&p))<>empty or trim(request("FD1_good_namea"&x&p))<>empty then
						SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
						SQL6=SQL6&"('" & request("F_tscode") & "','" & RSno & "','"& case_sqlno &"','"&trim(request("classa"&x&p))&"'"
						SQL6=SQL6&",'"&trim(request("FD1_good_namea"&x&p))&"','"&trim(request("FD1_good_counta"&x&p))&"',"
						SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
					ELSE
						SQL6=""
					end if
					'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "13=" & SQL6 & "<hr>"
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
							isql=isql & "'" & RSno & "','" & case_sqlno & "'," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
							'Response.Write "insert-casedmt_show="&isql&"<br>"
							cmd.CommandText=isql
							If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & isql & "<hr>"
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
						SQL6=SQL6&"('" & request("F_tscode") & "','" & RSno & "','"& case_sqlno &"','"&trim(request("classb"&x&p))&"'"
						SQL6=SQL6&",'"&trim(request("FD2_good_nameb"&x&p))&"','"&trim(request("FD2_good_countb"&x&p))&"',"
						SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
					ELSE
						SQL6=""
					end if
					'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL6 & "<hr>"
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
						isql=isql & "'" & RSno & "','" & case_sqlno & "'," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
						'Response.Write "insert-casedmt_show="&isql&"<br>"
						cmd.CommandText=isql
						If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & isql & "<hr>"
						cmd.Execute(isql)
					end if		
				next
			end if	 
		
	End Select
	
	
	
	'分割子案申請人入檔	
			insert_dmt_temp_ap(conn, RSno,case_sqlno);	

	next 
End IF
'Response.End

	//後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//更新客戶主檔最近立案日
	upd_dmt_date(conn, RSno);

	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans
	
End sub
%>

<!--#include file="CaseForm/ShowDoneBox.inc"-->