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
	
	'*****若為新案則新增至案件檔,舊案則不用
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
			SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,"
			sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"	
				  
			SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
						
			cmd.CommandText=SQL3
			If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & SQL3 & "<hr>"
			cmd.Execute(SQL3)	

'****次委辦案性			
	sql5 = "INSERT INTO caseitem_dmt (in_scode,in_no,item_sql,seq,seq1,item_arcase,item_service,item_fees,item_count) values"

'商品類別	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & RSno & "','"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			IF SQL6<>EMPTY THEN
				cmd.CommandText=SQL6
				If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & SQL6 & "<hr>"
				cmd.Execute(SQL6)
			END IF
		next
	 End IF

            //****新增展覽優先權資料
            insert_casedmt_show(conn, RSno);

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

if left(arcase,3)="FOB" then
	if trim(request("tfg1_other_item"))<>empty then
		SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,tr_date,tr_scode,seq,seq1,agt_no1)" & _
		  " values ('" & Request("F_tscode") & "','" & RSno & "'," & pkStr(Request("tfg1_other_item"),"") & _
		  ",'" & date() & "','" & session("se_scode") & "'," &  _
		  ""& Request("tfg1_seq")&",'"& Request("tfg1_seq1")&"','"& Request("tfg1_agt_no1") &"')"
		cmd.CommandText=SQL3
		If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & SQL3 & "<hr>"
		cmd.Execute(SQL3)	
	end if
ElseIF left(arcase,3)="AD7" then
	SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)" & _
	    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("fr4_other_item") & "'," & _
	    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
	    "'" & request("fr4_tran_remark1") & "','" & request("fr4_tran_mark") & "','" & date() & "','" & session("se_scode") & "'," & _
		Request("tfg1_seq") &",'"& Request("tfzb_seq1")&"')"
	cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & SQL3 & "<hr>"
	cmd.Execute(SQL3)
	'新增對照當事人資料
	for k=1 to request("de1_apnum")
	    sql3 = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values ("
	    sql3 = sql3 & "'" & request("F_tscode") & "','" & RSno & "','mod_client','" & trim(request("tfr4_ncname1_" & k)) & "','" & trim(request("tfr4_naddr1_" & k)) & "')"
	    cmd.CommandText=SQL3
	    If Trim(Request("chkTest"))<>Empty Then Response.Write "10=" & SQL3 & "<hr>"
		cmd.Execute(SQL3) 
	next 	
ElseIF left(arcase,3)="AD8" then
	SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)" & _
	    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("fr4_other_item") & "'," & _
	    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
	    "'" & request("fr4_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
		Request("tfg1_seq") &",'"& Request("tfzb_seq1")&"')"

	cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "11=" & SQL3 & "<hr>"
	cmd.Execute(SQL3)
elseif left(arcase,3)="FOF" then
    SQL3= "insert into dmt_tran(in_scode,in_no,seq,seq1,agt_no1,debit_money,other_item,other_item1,other_item2,tr_date,tr_scode) " & _
          "values ('" & request("F_tscode") & "','" & RSno & "'," & request("tfg1_seq")	&",'" & request("tfg1_seq1") & "','" & request("tfzf_agt_no1") & "'," & _
          request("tfzf_debit_money") & ",'" & trim(request("tfzf_other_item")) & "','" & trim(request("tfzf_other_item1")) & "','" & trim(request("tfzf_other_item2")) & "'," & _
          "getdate(),'" & session("se_scode") & "')"
    cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "12=" & SQL3 & "<hr>"
	cmd.Execute(SQL3)   
elseif left(arcase,3)="FB7" then
    SQL3= "insert into dmt_tran(in_scode,in_no,seq,seq1,agt_no1,other_item,tr_date,tr_scode) " & _
          "values ('" & request("F_tscode") & "','" & RSno & "','" & request("tfzb_seq")&"','" & request("tfzb_seq1") & "','" & request("tfb7_agt_no1") & "'," & _
          "'" & trim(request("tfb7_other_item")) & "'," & _
          "getdate(),'" & session("se_scode") & "')"
	'Response.Write sql3&"<br>"
	'Response.End
    cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "13=" & SQL3 & "<hr>"
	cmd.Execute(SQL3) 
elseif left(arcase,3)="FW1" then
    SQL3= "INSERT INTO dmt_tran(in_scode,in_no,mod_claim1,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1,other_item)" & _
		  " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("tfw1_mod_claim1") & "'," & pkStr(request("tfw1_tran_remark1"),"") & _
		  ",'" & date() & "','" & session("se_scode") & "'," &  _
		  Request("tfg1_seq") &",'"& Request("tfg1_seq1")&"','"& Request("tfg1_agt_no1") &"','" & request("tfw1_other_item") & "')"
	cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & SQL3 & "<hr>"
	cmd.Execute(SQL3)	 	   		
else
	SQL3= "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)" & _
		  " values ('" & Request("F_tscode") & "','" & RSno & "'," & pkStr(request("tfg1_tran_remark1"),"") & _
		  ",'" & date() & "','" & session("se_scode") & "'," &  _
		  Request("tfg1_seq") &",'"& Request("tfg1_seq1")&"','"& Request("tfg1_agt_no1") &"')"
	cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL3 & "<hr>"
	cmd.Execute(SQL3)
end if	
'Response.Write SQL3
'Response.End

'Response.Write "dmt_tran="&SQL3&"<br><br><br>"
'Response.End

if trim(request("tfg1_other_item"))<>empty then
	for i=2 to 11 
		'Response.Write "P"&i&"="&trim(request("ttz1_P"&i))&"<br><br>"
		if trim(request("ttz1_P"&i))<>empty then
				SQL7="INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_dclass,new_no) values ("
				SQL7= SQL7 & " '"& Request("F_tscode") &"','" & RSno & "','other_item','"&Request("ttz1_P"&i)&"','"&trim(Request("P"&i&"_mod_dclass"))&"','"&trim(Request("P"&i&"_new_no"))&"' )"
				cmd.CommandText=SQL7
				If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & SQL7 & "<hr>"
				cmd.Execute(SQL7)	
		'Response.Write "dmt_tranlist="&SQL7&"<br><br>"
		end if
	next 
end if

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

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