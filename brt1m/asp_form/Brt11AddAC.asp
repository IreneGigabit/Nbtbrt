<%
Sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	
	
'******************���ͬy����

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"
	
	sql = "INSERT INTO case_dmt("


	'�N�ɮק���ɦW
	aa=request("draw_file")
	if trim(request("tfy_case_stat"))<>"OO"  then
		if trim(aa) <> empty then
			'IF ubound(split(trim(request("draw_file")),"\"))=0 then
			IF ubound(split(trim(request("draw_file")),"/"))=0 then
				'filesource = server.MapPath(filepath) & "\" & aa 'temp
				'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
				'fso.MoveFile filesource,newfilename
				'aa=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
				'2013/11/26�ק�i�H�����ɦW�W�Ǥε������|
				strpath="/btbrt/" & session("se_branch") & "T/temp"
				attach_name = RSno & "." & right(aa,len(aa)-InstrRev(aa,"."))	'���s�R�W�ɦW
				newfilename = strpath & "/" & attach_name	'�s�b��Ʈw���|
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
				'2013/11/26�ק�i�H�����ɦW�W�Ǥε������|
				strpath="/btbrt/" & session("se_branch") & "T/temp"
				attach_name = RSno & "." & right(aa,len(aa)-InstrRev(aa,"."))	'���s�R�W�ɦW
				newfilename = strpath & "/" & attach_name	'�s�b��Ʈw���|
				call renameFile_nobackup(strpath,aa,attach_name)	
			else
				newfilename = ""
			end if
		else
			newfilename = trim(request("draw_file"))
		End IF
	end if
	'*****�Y���s�׫h�s�W�ܮץ���,�®׫h����
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

'****���e��ש�			
	sql5 = "INSERT INTO caseitem_dmt (in_scode,in_no,item_sql,seq,seq1,item_arcase,item_service,item_fees,item_count) values"

'�ӫ~���O	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then '2015/10/21�W�[�P�_�Y���ӫ~�]�J�A�]�ҩ��г��ι���г��L���O���|���ҩ����e
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


'****�s�W�ܮץ󲧰���
		sql = "INSERT INTO dmt_tran("
				sqlValue = ") VALUES("
				for each x in request.form
					if request(x) <> "" then
						if mid(x,2,3) = "fg1" then
						select case left(x,1)
								case "p"
									sql = sql & mid(x,6) & ","
									sqlValue = sqlValue & pkStr(request(x),",")
								case "d"
									sql = sql & mid(x,6) & ","
									sqlValue = sqlValue & pkdate(request(x),",")								
								case else
									sql = sql & mid(x,6) & ","
									sqlValue = sqlValue & pkStr(request(x),",")
						end select
						end if
					end if 
				next
		
		SQL=SQL & "in_scode, in_no,tr_date,tr_scode,"
		sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & session("se_scode") & "',"	
	
		SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"


	cmd.CommandText=SQL3
	If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & SQL3 & "<hr>"
	cmd.Execute(SQL3)	
	
	
	//�g�J���ӽФH��
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****�s�W���W��
	insert_dmt_attach(conn, RSno);

	//������@�~�A��s�笢�x���T�{������grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//��s�Ȥ�D�ɳ̪�߮פ�
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