<% 
Sub doUpdateDB()

'dmt_tranlist入log_table
call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))
stSQL = "delete from  dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_dmt'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)

update_case_dmt();

update_dmt_temp();


insert_caseitem_dmt();

'商品類別	
	ctrlnum=trim(request("ctrlnum2"))
	IF trim(Request("tfzd_class_count"))<>empty then
		for i=1 to ctrlnum
			if request("tfzd_s_mark")="L" or request("tfzd_s_mark")="M" then '2015/10/21增加檢查證明標章或團體標章沒有類別但有商品也要入商品檔
				if trim(request("good_name2"&i))<>empty then
					SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
					SQL6=SQL6&"('" & request("F_tscode") & "','" & request("In_no") & "','"&trim(request("class2"&i))&"','"&trim(request("grp_code2"&i))&"'"
					SQL6=SQL6&",'"&trim(request("good_name2"&i))&"','"&trim(request("good_count2"&i))&"',"
					SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
				ELSE
					SQL6=""
				end if
			else
				if trim(request("class2"&i))<>empty then
					SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
					SQL6=SQL6&"('" & request("F_tscode") & "','" & request("In_no") & "','"&trim(request("class2"&i))&"','"&trim(request("grp_code2"&i))&"'"
					SQL6=SQL6&",'"&trim(request("good_name2"&i))&"','"&trim(request("good_count2"&i))&"',"
					SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
				ELSE
					SQL6=""
				end if
			end if	
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & SQL6 & "<hr>"
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
				If Trim(Request("chkTest"))<>Empty Then Response.Write "10=" & iSQL & "<hr>"
				cmd.Execute(isql)
		   end if		
	   next
	end if

'***異動檔
'dmt_tran入log
call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 

sql = "UPDATE dmt_tran SET"
sqlWhere = ""
	for each x in request.form
		if mid(x,1,4) = "tfgp" then
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

	 '2012/9/5因備註選項修改
	 if request("O_item")="1" then
		if request("O_item1") <>empty or Request("O_item2") <>empty then
			SQL=SQL & "other_item='" & request("O_item") & "," & Request("O_item1") & ";" & Request("O_item2") 
			sql=sql & "',"
		end if			
	 elseif request("O_item")="Z" then
	    SQL=SQL & "other_item='" & request("O_item") & ";ZZ," & trim(Request("O_item2t")) 
		sql=sql & "',"
	 end if			
	 sql = sql & " seq = " & request("tfzb_seq") & ","& _
			     " seq1 = '" & request("tfzb_seq1") & "',"	      
	 sql=  sql & "in_scode = '" & request("F_tscode") & "',"
	 sql = sql & " tr_date  = '" & date() & "'," & " tr_scode = '" & session("se_scode") & "',"
	 sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
	 SQL = left(sql,len(sql)-1) & sqlWhere

	 cmd.CommandText=SQL
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "11=" & SQL & "<hr>"
	 cmd.Execute(SQL)
	 
 '*****變更事項1
 if Request("tfgp_mod_dmt") = "Y" then	 
	SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1" 
	SQL = SQL & ") VALUES('" & Request("F_tscode") & "','" & request("In_no") & "','mod_dmt','"&Request("new_appl_name")&"')"
	cmd.CommandText=SQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "12=" & SQL & "<hr>"
	cmd.Execute(SQL)
 End if
'Response.Write SQL
'Response.End

'申請人入log_table
	 call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
	 dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=0"
	 cmd.CommandText=dSQL7
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "13=" & dSQL7 & "<hr>"
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
			If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
		End IF
		'Response.Write "apnum="&SQL7&"<br>"
	next
	
    '*****文件上傳
    call updmt_attach_forcase(cnn,tprgid,request("in_no"))

  '後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   cmd.CommandText=SQL4	
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL4 & "<hr>"
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
	set cmd=Server.CreateObject("ADODB.command")
	set cnn=Server.CreateObject("ADODB.connection")
	cnn.Open session("btbrtdb")
	cmd.ActiveConnection=cnn
	cnn.BeginTrans	

'商品入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_good","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))   
stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'展覽優先權入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_show","in_no;case_sqlno",trim(request("in_no"))&";0")
stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'dmt_tranlist入log_table
call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))
stSQL = "delete from  dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_dmt'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & stSQL & "<hr>"
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
  If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL & "<hr>"
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
	'Response.Write newfilename & "<br>"
	'Response.End
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
			   " tr_scode = '" & session("se_scode") & "',"
   sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
   sql = left(sql,len(sql)-1) & sqlWHERE
  'Response.Write sql&"<br>"
  'Response.End
   cmd.CommandText=SQL
   If Trim(Request("chkTest"))<>Empty Then Response.Write "20=" & SQL & "<hr>"
   cmd.Execute(SQL)


'商品類別	
	ctrlnum=trim(request("ctrlnum2"))
	IF trim(Request("tfzd_class_count"))<>empty then
		for i=1 to ctrlnum
			if request("tfzd_s_mark")="L" or request("tfzd_s_mark")="M" then '2015/10/21增加檢查證明標章或團體標章沒有類別但有商品也要入商品檔
				if trim(request("good_name2"&i))<>empty then
					SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
					SQL6=SQL6&"('" & request("in_scode") & "','" & request("In_no") & "','"&trim(request("class2"&i))&"','"&trim(request("grp_code2"&i))&"'"
					SQL6=SQL6&",'"&trim(request("good_name2"&i))&"','"&trim(request("good_count2"&i))&"',"
					SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
				ELSE
					SQL6=""
				end if
			else
				if trim(request("class2"&i))<>empty then
					SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
					SQL6=SQL6&"('" & request("in_scode") & "','" & request("In_no") & "','"&trim(request("class2"&i))&"','"&trim(request("grp_code2"&i))&"'"
					SQL6=SQL6&",'"&trim(request("good_name2"&i))&"','"&trim(request("good_count2"&i))&"',"
					SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
				ELSE
					SQL6=""
				end if
			end if	
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "21=" & SQL6 & "<hr>"
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
				If Trim(Request("chkTest"))<>Empty Then Response.Write "22=" & iSQL & "<hr>"
				cmd.Execute(isql)
		   end if		
	   next
	end if


'***異動檔
'dmt_tran入log
call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 	

sql = "UPDATE dmt_tran SET"
sqlWhere = ""
	for each x in request.form
		if mid(x,1,4) = "tfgp" then
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

	 if request("O_item1") <>empty or Request("O_item2") <>empty then
		 SQL = SQL & " other_item='"& Request("O_item1") & ";" & Request("O_item2")
		 sql = sql & "',"
	 end if			
	 sql = sql & " tr_date  = '" & date() & "'," & " tr_scode = '" & session("se_scode") & "',"
	 sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
	 SQL = left(sql,len(sql)-1) & sqlWhere

	 cmd.CommandText=SQL
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "23=" & SQL & "<hr>"
	 cmd.Execute(SQL)
'Response.Write SQL
'Response.End
	 
	'*****變更事項1
 if Request("tfgp_mod_dmt") = "Y" then	 
	SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1" 
	SQL = SQL & ") VALUES('" & Request("in_scode") & "','" & request("In_no") & "','mod_dmt','"&Request("new_appl_name")&"')"
	cmd.CommandText=SQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "24=" & SQL & "<hr>"
	cmd.Execute(SQL)
 End if

'申請人入log_table
	 call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
	 dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=0"
	 cmd.CommandText=dSQL7
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "25=" & dSQL7 & "<hr>"
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
			If Trim(Request("chkTest"))<>Empty Then Response.Write "26=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
		End IF
		'Response.Write "apnum="&SQL7&"<br>"
	next

   '*****文件上傳
   call updmt_attach_forcase(cnn,tprgid,request("in_no"))

	'後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   cmd.CommandText=SQL4	
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "27=" & SQL4 & "<hr>"
	   cmd.Execute(SQL4)
	End if 
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
		If Trim(Request("chkTest"))<>Empty Then Response.Write "28=" & SQL & "<hr>"
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
