<%
sub doUpdateDB()

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
	filename = Rsno
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
    'set fso=nothing	

	select case left(Request("tfy_arcase"),3)
	case "DR1"
	   mod_class_ncname1=move_file(RSno,Request("ttg1_mod_class_ncname1"),"ttg1_mod_class_ncname1")
	   mod_class_ncname2=move_file(RSno,Request("ttg1_mod_class_ncname2"),"ttg1_mod_class_ncname2")
	   mod_class_nename1=move_file(RSno,Request("ttg1_mod_class_nename1"),"ttg1_mod_class_nename1")
	   mod_class_nename2=move_file(RSno,Request("ttg1_mod_class_nename2"),"ttg1_mod_class_nename2")
	   mod_class_ncrep=move_file(RSno,Request("ttg1_mod_class_ncrep"),"ttg1_mod_class_ncrep")
	   mod_class_nerep=move_file(RSno,Request("ttg1_mod_class_nerep"),"ttg1_mod_class_nerep")
	   mod_class_neaddr1=move_file(RSno,Request("ttg1_mod_class_neaddr1"),"ttg1_mod_class_neaddr1")
	   mod_class_neaddr2=move_file(RSno,Request("ttg1_mod_class_neaddr2"),"ttg1_mod_class_neaddr2")
	   mod_class_neaddr3=move_file(RSno,Request("ttg1_mod_class_neaddr3"),"ttg1_mod_class_neaddr3")
	   mod_class_neaddr4=move_file(RSno,Request("ttg1_mod_class_neaddr4"),"ttg1_mod_class_neaddr4")
	   '--據以異議
	   mod_dmt_ncname1=move_file(RSno,Request("ttg1_mod_dmt_ncname1"),"ttg1_mod_dmt_ncname1")
	   mod_dmt_ncname2=move_file(RSno,Request("ttg1_mod_dmt_ncname2"),"ttg1_mod_dmt_ncname2")
	   mod_dmt_nename1=move_file(RSno,Request("ttg1_mod_dmt_nename1"),"ttg1_mod_dmt_nename1")
	   mod_dmt_nename2=move_file(RSno,Request("ttg1_mod_dmt_nename2"),"ttg1_mod_dmt_nename2")
	   mod_dmt_ncrep=move_file(RSno,Request("ttg1_mod_dmt_ncrep"),"ttg1_mod_dmt_ncrep")
	   mod_dmt_nerep=move_file(RSno,Request("ttg1_mod_dmt_nerep"),"ttg1_mod_dmt_nerep")
	   mod_dmt_neaddr1=move_file(RSno,Request("ttg1_mod_dmt_neaddr1"),"ttg1_mod_dmt_neaddr1")
	   mod_dmt_neaddr2=move_file(RSno,Request("ttg1_mod_dmt_neaddr2"),"ttg1_mod_dmt_neaddr2")
	   mod_dmt_neaddr3=move_file(RSno,Request("ttg1_mod_dmt_neaddr3"),"ttg1_mod_dmt_neaddr3")
	   mod_dmt_neaddr4=move_file(RSno,Request("ttg1_mod_dmt_neaddr4"),"ttg1_mod_dmt_neaddr4")
	case "DO1"
	   mod_dmt_ncname1=move_file(RSno,Request("ttg2_mod_dmt_ncname1"),"ttg2_mod_dmt_ncname1")
	   mod_dmt_ncname2=move_file(RSno,Request("ttg2_mod_dmt_ncname2"),"ttg2_mod_dmt_ncname2")
	   mod_dmt_nename1=move_file(RSno,Request("ttg2_mod_dmt_nename1"),"ttg2_mod_dmt_nename1")
	   mod_dmt_nename2=move_file(RSno,Request("ttg2_mod_dmt_nename2"),"ttg2_mod_dmt_nename2")
	   mod_dmt_ncrep=move_file(RSno,Request("ttg2_mod_dmt_ncrep"),"ttg2_mod_dmt_ncrep")
	   mod_dmt_nerep=move_file(RSno,Request("ttg2_mod_dmt_nerep"),"ttg2_mod_dmt_nerep")
	   mod_dmt_neaddr1=move_file(RSno,Request("ttg2_mod_dmt_neaddr1"),"ttg2_mod_dmt_neaddr1")
	   mod_dmt_neaddr2=move_file(RSno,Request("ttg2_mod_dmt_neaddr2"),"ttg2_mod_dmt_neaddr2")
	   mod_dmt_neaddr3=move_file(RSno,Request("ttg2_mod_dmt_neaddr3"),"ttg2_mod_dmt_neaddr3")
	   mod_dmt_neaddr4=move_file(RSno,Request("ttg2_mod_dmt_neaddr4"),"ttg2_mod_dmt_neaddr4")
	case "DI1"
	   mod_dmt_ncname1=move_file(RSno,Request("ttg3_mod_dmt_ncname1"),"ttg3_mod_dmt_ncname1")
	   mod_dmt_ncname2=move_file(RSno,Request("ttg3_mod_dmt_ncname2"),"ttg3_mod_dmt_ncname2")
	   mod_dmt_nename1=move_file(RSno,Request("ttg3_mod_dmt_nename1"),"ttg3_mod_dmt_nename1")
	   mod_dmt_nename2=move_file(RSno,Request("ttg3_mod_dmt_nename2"),"ttg3_mod_dmt_nename2")
	   mod_dmt_ncrep=move_file(RSno,Request("ttg3_mod_dmt_ncrep"),"ttg3_mod_dmt_ncrep")
	   mod_dmt_nerep=move_file(RSno,Request("ttg3_mod_dmt_nerep"),"ttg3_mod_dmt_nerep")
	   mod_dmt_neaddr1=move_file(RSno,Request("ttg3_mod_dmt_neaddr1"),"ttg3_mod_dmt_neaddr1")
	   mod_dmt_neaddr2=move_file(RSno,Request("ttg3_mod_dmt_neaddr2"),"ttg3_mod_dmt_neaddr2")
	   mod_dmt_neaddr3=move_file(RSno,Request("ttg3_mod_dmt_neaddr3"),"ttg3_mod_dmt_neaddr3")
	   mod_dmt_neaddr4=move_file(RSno,Request("ttg32_mod_dmt_neaddr4"),"ttg3_mod_dmt_neaddr4")
	end select	
    'Response.Write "issue_no=" & request("tfzd_issue_no")&"<br>"
    'Response.End
	'****新案變更新增至案件主檔	
			sql = "INSERT INTO dmt_temp("
			sqlValue = ") VALUES("
			for each x in request.form
				if request(x) <> "" then
					if mid(x,2,3) = "fzb" or mid(x,2,3) = "fzd" or mid(x,2,3) = "fzp" then
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
			'2010/10/4修改異議、評定及廢止也入類別資料
			'IF left(arcase,3)<>"DR1" or left(arcase,3)<>"DO1" or left(arcase,3)<>"DI1" then
				IF request("tfzr_class_count") <> empty then		 
					sql=sql & "class_type,class_count,class,"
					sqlValue = sqlvalue & " '" & request("tfzr_class_type") & "', '" & Request("tfzr_class_count") & "','"&request("tfzr_class")&"',"
				End if
			'End IF
			
			SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,"
			sqlvalue= sqlvalue & " '" & request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"	
			SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
			'Response.Write sql3&"<br>"
	'Response.End
			cmd.CommandText=SQL3
			If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & SQL3 & "<hr>"
			cmd.Execute(SQL3)	
			
if trim(Request("tfzb_seq")) = "" then
   tfzb_seq="null"	
else
   tfzb_seq=Request("tfzb_seq")
end if	

	'****次委辦案性			
	sql5 = "INSERT INTO caseitem_dmt (in_scode,in_no,item_sql,seq,seq1,item_arcase,item_service,item_fees,item_count) values"

	'*****新增案件變更檔
	select case left (Request("tfy_arcase"),3)
	case "DR1":%><!--#include file="caseForm/AddDR1.inc"-->
	<%case "DO1":%><!--#include file="caseForm/AddDO1.inc"-->
	<%case "DI1":%><!--#include file="caseForm/AddDI1.inc"-->
    <%case else
			'商品類別	
			ctrlnum=trim(request("ctrlnum1"))
			IF trim(Request("tfzr_class_count"))<>empty then
				for i=1 to ctrlnum
					if trim(request("class1"&i))<>empty or trim(request("good_name1"&i))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
						SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
						SQL6=SQL6&"('" & request("F_tscode") & "','" & RSno & "','"&trim(request("class1"&i))&"','"&trim(request("grp_code1"&i))&"'"
						SQL6=SQL6&",'"&trim(request("good_name1"&i))&"','"&trim(request("good_count1"&i))&"',"
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
			if trim(Request("tfzb_seq")) = "" then
			   tfg1_seq="null"	
			else
			   tfg1_seq=Request("tfzb_seq")				
			end if
			IF left (Request("tfy_arcase"),3)="DE1" then
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)" & _
				    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("fr4_other_item") & "'," & _
				    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
				    "'" & request("fr4_tran_remark1") & "','" & request("fr4_tran_mark") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfg1_seq &",'"& Request("tfzb_seq1")&"')"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)
				'新增對照當事人資料
				for k=1 to request("de1_apnum")
				    sql3 = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values ("
				    sql3 = sql3 & "'" & request("F_tscode") & "','" & RSno & "','mod_client','" & trim(request("tfr4_ncname1_" & k)) & "','" & trim(request("tfr4_naddr1_" & k)) & "')"
				    cmd.CommandText=SQL3
				    If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & SQL3 & "<hr>"
					cmd.Execute(SQL3) 
				next 	
			ElseIF left (Request("tfy_arcase"),3)="DE2" then
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)" & _
				    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("fr4_other_item") & "'," & _
				    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
				    "'" & request("fr4_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfg1_seq &",'"& Request("tfzb_seq1")&"')"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)	
			Else
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)" & _
				    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("tfg1_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfg1_seq &",'"& Request("tfzb_seq1")&"',"& pkStr(Request("tfg1_agt_no1"),"") &")"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)				
			End IF
	end select

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

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