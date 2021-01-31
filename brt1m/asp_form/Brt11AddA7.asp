<% 
Sub doUpdateDB()
ntag = "1" 

'dmt_tranlist入log_table
call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))	
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_class'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)
'刪除case_dmt1
dsql="delete from case_dmt1 where in_no='" & request("in_no") & "'"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & dSQL & "<hr>"
cmd.Execute(dsql)
'刪除子案dmt_temp
dsql="delete from dmt_temp where in_no='" & request("in_no") & "' and case_sqlno<>0"
cmd.CommandText=dsql
If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & dSQL & "<hr>"
cmd.Execute(dsql)


update_case_dmt();

update_dmt_temp();

insert_caseitem_dmt();



'商品類別	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "',0,'"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "13=" & SQL6 & "<hr>"
					cmd.Execute(SQL6)
				END IF
		next
	 End IF		

'新增展覽優先權
shownum=request("shownum_dmt")
	if shownum>0 then
	   for i=1 to shownum
	       if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
				isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
				isql=isql & "'" & request("in_no") & "',0," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
				'Response.Write "insert-casedmt_show="&isql&"<br>"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & iSQL & "<hr>"
				Conn.Execute(isql)
		   end if		
	   next
	end if
			
'*****移轉檔	
	'dmt_tran入log
	call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
	sql = "UPDATE dmt_tran SET "   
	sqlWhere = ""
	for each x in request.form
	     if mid(x,2,3) = "fg" & ntag then				 
	    			select case left(x,1)		       
						 case "d"
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
						 case "n"
							 sql = sql & " " & mid(x,6) & "=" & drn(x)
						 case else
							 if x="tfg1_seq" then
								sql = sql & " " & mid(x,6) & "=" & drn(x)
							 else
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
							 end if
					 end select
	     end if
  next
  if request("O_item1") <>empty or Request("O_item2") <>empty then
		 sql = sql & " other_item = '" & Request("O_item1") & ";" & Request("O_item2") & "'," 	
  end if
  if request("other_item2")<>empty then
     sql=sql & "other_item2="
     if request("other_item2t")<>empty then
        sql = sql & " '" & request("other_item2") & "," & trim(request("other_item2t")) & "',"
     else
		sql = sql & " '" & request("other_item2") & "',"   
     end if   
  end if		
  sql = sql & " tr_date  = '" & date() & "'," & _
			  " tr_scode = '" & session("se_scode") & "',"
  SQL=  sql & "in_scode = '" & request("F_tscode") & "',"	
  sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
  sql = left(sql,len(sql)-1) & sqlWHERE  
  cmd.CommandText=SQL
  If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL & "<hr>"
  cmd.Execute(SQL)
  
'*****新增案件異動明細檔，關係人資料	
    dsql="delete from dmt_tranlist where in_no='" & trim(request("in_no")) & "' and in_scode='" & trim(request("in_scode")) & "' and mod_field='mod_ap'"
    cmd.CommandText=dSQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & dSQL & "<hr>"
	cmd.Execute(dSQL)
	for k=1 to request("fl_apnum")
		 ocname1 = replace(trim(request("tfr_ocname1_" & k)),"'","’")
		 if instr(ocname1,"&#") > 0 then
		 else
			ocname1 = replace(ocname1,"&","＆")
		 end if	
		 ocname2 = replace(trim(request("tfr_ocname2_" & k)),"'","’")
		 if instr(ocname2,"&#") > 0 then
		 else
			ocname2 = replace(ocname2,"&","＆")
		 end if	
		 oename1 = replace(trim(request("tfr_oename1_" & k)),"'","’")
		 if instr(oename1,"&#") > 0 then
		 else
			oename1 = replace(oename1,"&","＆")
		 end if	
		 oename2 = replace(trim(request("tfr_oename2_" & k)),"'","’")
		 if instr(oename2,"&#") > 0 then
		 else
			oename2 = replace(oename2,"&","＆")
		 end if	
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2,"
         sql3=sql3 & "ocrep,oerep,ozip,oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,oapclass,oap_country,"
         sql3=sql3 & "tran_code) values('" & request("in_scode") & "','" & request("in_no") & "','mod_ap','" & request("tfr_old_no"&k) & "'"
         sql3=sql3 & ",'" & ocname1 & "','" & ocname2 & "','" & oename1 & "','" & oename2 & "','" & trim(request("tfr_ocrep"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oerep"&k)) & "','" & trim(request("tfr_ozip"&k)) & "','" & trim(request("tfr_oaddr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oaddr2_"&k)) & "','" & trim(request("tfr_oeaddr1_" & k)) & "','" & trim(request("tfr_oeaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oeaddr3_"&k)) & "','" & trim(request("tfr_oeaddr4_"&k)) & "','" & trim(request("tfr_otel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_otel"&k)) & "','" & trim(request("otel1_"&k)) & "','" & trim(request("ofax"&k)) & "','" & trim(request("tfr_oapclass"&k)) & "','" & trim(request("tfr_oap_country"&k)) & "','N')"
		 cmd.CommandText=SQL3	
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)    
	 next    

''*****新增案件異動明細檔	
if Arcase="FL1" or arcase="FL5" then
		for i=1 to request("ctrlnum2")
			sql = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark) "
			sql = sql & "VALUES('" & Request("F_tscode") & "','" & Request("in_no") & "','mod_class','"&request("tfl1_mod_type")&"','"&request("mod_count")&"','"&request("mod_dclass")&"','"&request("new_no"&i)&"','"&request("list_remark"&i)&"')"
			cmd.CommandText=SQL
			If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & SQL & "<hr>"
			cmd.Execute(SQL)
		next 
elseif Arcase="FL2" or arcase="FL6" then
	'2012/7/1新申請書增加指定使用商品種類全部或部份
		for i=1 to request("ctrlnum2")
			sql = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark) "
			sql = sql & "VALUES('" & Request("F_tscode") & "','" & Request("in_no") & "','mod_class','" & request("tfl1_mod_type") & "','"&request("mod_count")&"','"&request("mod_dclass")&"','"&request("new_no"&i)&"','"&request("list_remark"&i)&"')"
			'Response.Write sql&"<br>"
			cmd.CommandText=SQL
			If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL & "<hr>"
			cmd.Execute(SQL)
		next 
	'*****商標權人資料	
	 dsql="delete from dmt_tranlist where in_no='" & trim(request("in_no")) & "' and in_scode='" & trim(request("in_scode")) & "' and mod_field='mod_tap'"
    cmd.CommandText=dSQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "20=" & dSQL & "<hr>"
	cmd.Execute(dSQL) 	
	for k=1 to request("fl2_apnum")
		 ncname1 = replace(trim(request("tfv_ncname1_" & k)),"'","’")
		 if instr(ncname1,"&#") > 0 then
		 else
			ncname1 = replace(ncname1,"&","＆")
		 end if	
		 ncname2 = replace(trim(request("tfv_ncname2_" & k)),"'","’")
		 if instr(ncname2,"&#") > 0 then
		 else
			ncname2 = replace(ncname2,"&","＆")
		 end if	
		 nename1 = replace(trim(request("tfv_nename1_" & k)),"'","’")
		 if instr(nename1,"&#") > 0 then
		 else
			nename1 = replace(nename1,"&","＆")
		 end if	
		 nename2 = replace(trim(request("tfv_nename2_" & k)),"'","’")
		 if instr(nename2,"&#") > 0 then
		 else
		    nename2 = replace(nename2,"&","＆")
		 end if   
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,new_no,ncname1,ncname2,nename1,nename2,"
         sql3=sql3 & "ncrep,nerep,nzip,naddr1,naddr2,neaddr1,neaddr2,neaddr3,neaddr4,ntel0,ntel,ntel1,nfax,napclass,nap_country,"
         sql3=sql3 & "tran_code) values('" & request("in_scode") & "','" & request("in_no") & "','mod_tap','" & request("tfv_new_no"&k) & "'"
         sql3=sql3 & ",'" & ncname1 & "','" & ncname2 & "','" & nename1 & "','" & nename2 & "','" & trim(request("tfv_ncrep"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_nerep"&k)) & "','" & trim(request("tfv_nzip"&k)) & "','" & trim(request("tfv_naddr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_naddr2_"&k)) & "','" & trim(request("tfv_neaddr1_" & k)) & "','" & trim(request("tfv_neaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_neaddr3_"&k)) & "','" & trim(request("tfv_neaddr4_"&k)) & "','" & trim(request("tfv_ntel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_ntel"&k)) & "','" & trim(request("tfv_ntel1_"&k)) & "','" & trim(request("tfv_nfax"&k)) & "','" & trim(request("tfv_napclass"&k)) & "','" & trim(request("tfv_nap_country"&k)) & "','N')"
		 cmd.CommandText=SQL3	
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "21=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)
	next	         
end if
'申請人入log_table
 call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
 dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=0"
 cmd.CommandText=dSQL7
 If Trim(Request("chkTest"))<>Empty Then Response.Write "22=" & dSQL7 & "<hr>"
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
			If Trim(Request("chkTest"))<>Empty Then Response.Write "23=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
		End IF
		'Response.Write "apnum="&SQL7&"<br>"
next
'*****新增文件上傳
	call updmt_attach_forcase(cnn,tprgid,request("in_no"))
'	'入dmt_attach_log
'	call insert_log_table(conn,"U",tprgid,"dmt_attach","in_no",request("in_no"))
'	'***先清掉所有文件上傳資料	
 '   sql="Delete from dmt_attach where in_no = '" & request("In_no") & "'" 
  '  cmd.CommandText=SQL
  '  cmd.Execute(SQL)   
'	strpath="/btbrt/" & session("se_branch") & "T/"  & request("attach_path")
'	for k=1 to request("attachfilenum")
'		if trim(request("attach_name"&k))<>empty then
'		    straa=request("attach_name"&k)	'上傳檔名
'			attach_name = request("in_no") & "-" & k & "." & right(straa,len(straa)-InstrRev(straa,"."))	'重新命名檔名
'			newattach_path = strpath & "/" & attach_name	'存在資料庫路徑
'			if request("attach_flag"&k) = "A" then
'				call renameFile(strpath,strpath,straa,attach_name)
'				source_name=straa
'			else
'				source_name=request("source_name"&k)
'			end if	
'			sqlattach="insert into dmt_attach(seq,seq1,case_no,in_no,source,in_date,in_scode,attach_no,attach_path,doc_type,attach_desc,attach_name,source_name,attach_size,attach_flag,attach_branch,tran_date,tran_scode) values(" _
'		             & chknull(request("tfzb_seq")) & "," & pkstr(request("tfzb_seq1"),",") & pkstr(request("attach_case_no"),",") & pkstr(request("in_no"),",") & "'case',getdate()," & pkstr(session("se_scode"),",") & k & "," _
'		             & pkstr(newattach_path,",") & pkstr(request("doc_type"&k),",") & pkstr(trim(request("attach_desc"&k)),",") & pkstr(trim(attach_name),",") & pkstr(source_name,",") & pkstr(request("attach_size"&k),",") _
'		             & "'" & request("attach_flag"&k) & "','" & request("attach_branch"&k) & "',getdate(),'" & session("se_scode") & "')"
'		              
'		else
'			sqlattach=""
'		end if
''		Response.Write sqlattach
''		Response.End
'		if sqlattach<>"" then
'		   cmd.CommandText=sqlattach
'		   cmd.Execute(sqlattach)	
'		end if
'	next 
'授權及被授權多件入檔	
if arcase="FL5" or arcase="FL6" then
    'if session("se_scode")="m802" then
    '   Response.Write "num="&request("nfy_tot_num")&"<br>"
       'Response.End
    'end if 
	if request("nfy_tot_num")<>empty then
		
		for i=2 to request("nfy_tot_num")
		    if session("se_scode")="m802" then
				Response.Write "i="&i&"<br>"
				'Response.End
			end if 
			if trim(request("dseqb"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&request("in_no")&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "24=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqb"&i))<>empty then
					dseqb=trim(request("dseqb"&i))
				Else
					dseqb="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&request("in_no")&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"','NN')"
				'if session("se_scode")="m802" then
				'	Response.Write "2SQL="&SQL&"<br>"
					'Response.End
				'end if 
				If Trim(Request("chkTest"))<>Empty Then Response.Write "25=" & SQL & "<hr>"
				Conn.Execute(SQL)
			End IF
			SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1 "
			rsi.open sqlno,conn,1,1
			Case_sqlno=trim(rsi("case_sqlno"))
			rsi.close
			if trim(request("dseqb"&i))=empty then
				SQL3="SELECT * FROM  dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='L'"
				'if session("se_scode")="m802" then
				'	Response.Write "SQL3="&SQL3&"<br>"
					'Response.End
				'end if 
				RCreg.open SQL3,conn,1,1
				IF not RCreg.EOF Then
					filepath="/btbrt/" & session("se_branch") & "t/temp"
					'Response.Write filepath
					filename = request("in_no")&"-FC"&i
					aa=trim(RCreg("draw_file"))
					if trim(aa) <> empty then
						'IF ubound(split(trim(RCreg("draw_file")),"\"))=0 then
						IF ubound(split(trim(RCreg("draw_file")),"/"))=0 then
							'filesource = server.MapPath(filepath) & "\" & aa 'temp
							'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
							'fso.MoveFile filesource,newfilename
							'aa=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
							'2013/11/26修改可以中文檔名上傳及虛擬路徑
							strpath="/btbrt/" & session("se_branch") & "T/temp"
							attach_name = filename & "." & right(aa,len(aa)-InstrRev(aa,"."))	'重新命名檔名
							newfilename = strpath & "/" & attach_name	'存在資料庫路徑
							call renameFile_nobackup(strpath,aa,attach_name)
						else
							newfilename = trim(RCreg("draw_file"))
						End IF
					else
						newfilename = ""
					end if
			
						sql = "INSERT INTO dmt_temp("
								sqlValue = ") VALUES("
								IF trim(RCreg("S_mark"))<>empty then
									sql=sql&"s_mark,"
									sqlValue=sqlValue& "'"&Trim(RCreg("S_mark"))&"',"
								End IF
								IF trim(RCreg("s_mark2"))<>empty then
									sql=sql&"s_mark2,"
									sqlValue=sqlValue& "'"&Trim(RCreg("s_mark2"))&"',"
								End IF
								IF trim(RCreg("pul"))<>empty then
									sql=sql&"pul,"
									sqlValue=sqlValue& "'"&Trim(RCreg("pul"))&"',"
								End IF
								IF trim(request("tfzp_apsqlno"))<>empty then
									sql=sql&"apsqlno,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_apsqlno"))&"',"
								End IF
								IF trim(request("tfzp_ap_cname"))<>empty then
									sql=sql&"ap_cname,"
									sqlValue=sqlValue& "'"&Trim(request("tfzp_ap_cname"))&"',"
								End IF
								IF trim(request("tfzp_ap_cname1"))<>empty then
									sql=sql&"ap_cname1,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_cname1"))&"',"
								End IF
								IF trim(request("tfzp_ap_cname2"))<>empty then
									sql=sql&"ap_cname2,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_cname2"))&"',"
								End IF
								IF trim(request("tfzp_ap_ename"))<>empty then
									sql=sql&"ap_ename,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_ename"))&"',"
								End IF
								IF trim(request("tfzp_ap_ename1"))<>empty then
									sql=sql&"ap_ename1,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_ename1"))&"',"
								End IF
								IF trim(request("tfzp_ap_ename2"))<>empty then
									sql=sql&"ap_ename2,"
									sqlValue=sqlValue& "'"&trim(request("tfzp_ap_ename2"))&"',"
								End IF
								IF trim(RCreg("Appl_name"))<>empty then
									sql=sql&"appl_name,"
									sqlValue=sqlValue& "'"&Trim(RCreg("Appl_name"))&"',"
								End IF
								IF trim(RCreg("cappl_name"))<>empty then
									sql=sql&"cappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("cappl_name"))&"',"
								End IF
								IF trim(RCreg("eappl_name"))<>empty then
									sql=sql&"eappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("eappl_name"))&"',"
								End IF
								IF trim(RCreg("eappl_name1"))<>empty then
									sql=sql&"eappl_name1,"
									sqlValue=sqlValue& "'"&trim(RCreg("eappl_name1"))&"',"
								End IF
								IF trim(RCreg("eappl_name2"))<>empty then
									sql=sql&"eappl_name2,"
									sqlValue=sqlValue& "'"&trim(RCreg("eappl_name2"))&"',"
								End IF
								IF trim(RCreg("jappl_name"))<>empty then
									sql=sql&"jappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("jappl_name"))&"',"
								End IF
								IF trim(RCreg("jappl_name1"))<>empty then
									sql=sql&"jappl_name1,"
									sqlValue=sqlValue& "'"&trim(RCreg("jappl_name1"))&"',"
								End IF
								IF trim(RCreg("jappl_name2"))<>empty then
									sql=sql&"jappl_name2,"
									sqlValue=sqlValue& "'"&trim(RCreg("jappl_name2"))&"',"
								End IF
								IF trim(RCreg("zappl_name1"))<>empty then
									sql=sql&"zappl_name1,"
									sqlValue=sqlValue& "'"&trim(RCreg("zappl_name1"))&"',"
								End IF
								IF trim(RCreg("zappl_name2"))<>empty then
									sql=sql&"zappl_name2,"
									sqlValue=sqlValue& "'"&trim(RCreg("zappl_name2"))&"',"
								End IF
								IF trim(RCreg("zname_type"))<>empty then
									sql=sql&"zname_type,"
									sqlValue=sqlValue& "'"&trim(RCreg("zname_type"))&"',"
								End IF
								IF trim(RCreg("oappl_name"))<>empty then
									sql=sql&"oappl_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("oappl_name"))&"',"
								End IF
								IF trim(RCreg("Draw"))<>empty then
									sql=sql&"Draw,"
									sqlValue=sqlValue& "'"&trim(RCreg("Draw"))&"',"
								End IF
								IF trim(RCreg("symbol"))<>empty then
									sql=sql&"symbol,"
									sqlValue=sqlValue& "'"&trim(RCreg("symbol"))&"',"
								End IF
								IF trim(RCreg("color"))<>empty then
									sql=sql&"color,"
									sqlValue=sqlValue& "'"&trim(RCreg("color"))&"',"
								End IF
								IF trim(request("tfzd_agt_no"))<>empty then
									sql=sql&"agt_no,"
									sqlValue=sqlValue& "'"&trim(request("tfzd_agt_no"))&"',"
								End IF
								IF trim(RCreg("prior_date"))<>empty then
									sql=sql&"prior_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("prior_date"))&"',"
								End IF
								IF trim(RCreg("prior_no"))<>empty then
									sql=sql&"prior_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("prior_no"))&"',"
								End IF
								IF trim(RCreg("prior_country"))<>empty then
									sql=sql&"prior_country,"
									sqlValue=sqlValue& "'"&trim(RCreg("prior_country"))&"',"
								End IF
								IF trim(RCreg("ref_no"))<>empty then
									sql=sql&"ref_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("ref_no"))&"',"
								End IF
								IF trim(RCreg("ref_no1"))<>empty then
									sql=sql&"ref_no1,"
									sqlValue=sqlValue& "'"&trim(RCreg("ref_no1"))&"',"
								End IF
								'IF trim(request("tfzb_seq"))<>empty then
								'	sql=sql&"Mseq,"
								'	sqlValue=sqlValue& "'"&trim(request("tfzb_seq"))&"',"
								'End IF
								'IF trim(request("tfzb_seq1"))<>empty then
								'	sql=sql&"Mseq1,"
								'	sqlValue=sqlValue& "'_',"
								'End IF
								IF trim(RCreg("tcn_ref"))<>empty then
									sql=sql&"tcn_ref,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_ref"))&"',"
								End IF
								IF trim(RCreg("tcn_class"))<>empty then
									sql=sql&"tcn_class,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_class"))&"',"
								End IF
								IF trim(RCreg("tcn_name"))<>empty then
									sql=sql&"tcn_name,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_name"))&"',"
								End IF
								IF trim(RCreg("tcn_mark"))<>empty then
									sql=sql&"tcn_mark,"
									sqlValue=sqlValue& "'"&trim(RCreg("tcn_mark"))&"',"
								End IF
								IF trim(RCreg("apply_date"))<>empty then
									sql=sql&"apply_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("apply_date"))&"',"
								End IF
								IF trim(RCreg("apply_no"))<>empty then
									sql=sql&"apply_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("apply_no"))&"',"
								End IF
								IF trim(RCreg("issue_date"))<>empty then
									sql=sql&"issue_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("issue_date"))&"',"
								End IF
								IF trim(RCreg("issue_no"))<>empty then
									sql=sql&"issue_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("issue_no"))&"',"
								End IF
								IF trim(RCreg("open_date"))<>empty then
									sql=sql&"open_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("open_date"))&"',"
								End IF
								IF trim(RCreg("rej_no"))<>empty then
									sql=sql&"rej_no,"
									sqlValue=sqlValue& "'"&trim(RCreg("rej_no"))&"',"
								End IF
								IF trim(RCreg("end_date"))<>empty then
									sql=sql&"end_date,"
									sqlValue=sqlValue& "'"&trim(RCreg("end_date"))&"',"
								End IF
								IF trim(RCreg("end_code"))<>empty then
									sql=sql&"end_code,"
									sqlValue=sqlValue& "'"&trim(RCreg("end_code"))&"',"
								End IF
								IF trim(RCreg("dmt_term1"))<>empty then
									sql=sql&"dmt_term1,"
									sqlValue=sqlValue& "'"&trim(RCreg("dmt_term1"))&"',"
								End IF
								IF trim(RCreg("dmt_term2"))<>empty then
									sql=sql&"dmt_term2,"
									sqlValue=sqlValue& "'"&trim(RCreg("dmt_term2"))&"',"
								End IF
								IF trim(RCreg("renewal"))<>empty then
									sql=sql&"renewal,"
									sqlValue=sqlValue& "'"&trim(RCreg("renewal"))&"',"
								End IF
							sql=sql & "class_type,class_count,class,"
							sqlValue = sqlvalue & " '" & trim(RCreg("class_type")) & "','" & trim(RCreg("class_count")) & "','"&trim(RCreg("class"))&"',"
							SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,case_sqlno,seq1,"
							sqlvalue= sqlvalue & "'" & Request("in_scode") & "','" & request("in_no") & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &",'"&trim(request("dseq1b"&i))&"',"
							SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
							IF SQL7<>empty then
								cmd.CommandText=SQL7
								If Trim(Request("chkTest"))<>Empty Then Response.Write "26=" & SQL7 & "<hr>"
								cmd.Execute(SQL7)
							End IF
							'申請人資料畫面Apcust_FC_RE_form.inc
							'*****申請人檔
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
								SQL7 = SQL7 & "'"& request("in_no") &"'," & case_sqlno & ",'"& trim(request("apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
								SQL7 = SQL7 & ",'"& trim(request("apcust_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
								SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
								SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
								SQL7 = SQL7 & "," & chkzero(request("ap_sql"&apnum),2) & ",'" & trim(request("ap_zip"&apnum)) & "','" & trim(request("ap_addr1_"&apnum)) & "','" & trim(request("ap_addr2_"&apnum)) & "'"
								SQL7 = SQL7 & ",'" & trim(request("ap_eaddr1_"&apnum)) & "','" & trim(request("ap_eaddr2_"&apnum)) & "','" & trim(request("ap_eaddr3_"&apnum)) & "','" & trim(request("ap_eaddr4_"&apnum)) & "')" 
								'Response.Write "apnum="&SQL7&"<br>"
								'Response.End
								IF SQL7<>empty then
									cmd.CommandText=SQL7
									If Trim(Request("chkTest"))<>Empty Then Response.Write "27=" & SQL7 & "<hr>"
									cmd.Execute(SQL7)
								End IF
								'Response.Write "apnum="&SQL7&"<br>"
							next
				End IF
				RCreg.Close
				'商品類別	
				SQLno="SELECT *  FROM casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='L'"
				RCreg.open sqlno,conn,1,1
				IF not RCreg.EOF then
					For x=1 to RCreg.RecordCount
						if trim(RCreg("class"))<>empty or trim(RCreg("dmt_goodname"))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
							SQL6 = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
							SQL6=SQL6&"('" & request("in_scode") & "','" & request("in_no") & "',"&case_sqlno&",'"&trim(RCreg("class"))&"','"&trim(RCreg("dmt_grp_code"))&"'"
							SQL6=SQL6&",'"&trim(RCreg("dmt_goodname"))&"','"&trim(RCreg("dmt_goodcount"))&"',"
							SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>empty then
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "28=" & SQL6 & "<hr>"
							cmd.Execute(SQL6)
						End IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
				'展覽會優先權	
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='L'"
				SQLno=SQLno & " order by show_no "
				RCreg.open sqlno,conn,1,1
				IF not RCreg.EOF then
					For x=1 to RCreg.RecordCount
						if trim(RCreg("show_date"))<>empty or trim(RCreg("show_name"))<>empty then
							SQL6 = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values"
							SQL6=SQL6&"('" & request("in_no") & "',"&case_sqlno&",'"&trim(RCreg("show_date"))&"','"&trim(RCreg("show_name"))&"'"
							SQL6=SQL6&",getdate(),'" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						Response.Write "SQL6_casedmt_show="&SQL6&"<br><br><br>"
						IF SQL6<>empty then
							cmd.CommandText=SQL6
							If Trim(Request("chkTest"))<>Empty Then Response.Write "29=" & SQL6 & "<hr>"
							cmd.Execute(SQL6)
						End IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
			End IF
		next
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='L'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "30=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='L'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "31=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='L'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "32=" & SQL & "<hr>"
		Conn.execute(SQL)
	End IF
End IF		
'if session("se_scode")="m802" then
'Response.End
'end if 
 '後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   cmd.CommandText=SQL4	
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "33=" & SQL4 & "<hr>"
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
ntag = "1" 
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	

v=split(request("tfy_arcase"),"&")
arcase=v(0)
prt_code=v(1)

'商品入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_good","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))      
stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "34=" & stSQL & "<hr>"
cmd.Execute(stSQL)
'展覽優先權入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_show","in_no;case_sqlno",trim(request("in_no"))&";0")
stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno=0"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "35=" & stSQL & "<hr>"
cmd.Execute(stSQL)
'dmt_tranlist入log_table
call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))		
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_class'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "36=" & stSQL & "<hr>"
cmd.Execute(stSQL)

'***更新客戶及連絡人
'sql = "UPDATE case_dmt SET cust_area='"&trim(request("tfy_cust_area"))&"',cust_seq='"&trim(request("tfy_cust_seq"))&"',att_sql='"&trim(request("tfy_att_sql"))&"' " 
'sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
'sql = left(sql,len(sql)-1) & sqlWHERE
   
'  cmd.CommandText=SQL
'  cmd.Execute(SQL)
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
  If Trim(Request("chkTest"))<>Empty Then Response.Write "37=" & SQL & "<hr>"
  cmd.Execute(SQL)

'********案件檔
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
			'filesource = server.MapPath(filepath) & "\" & aa 'temp
			'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
			'if fso.FileExists(oldfilename) then
			'		fso.DeleteFile oldfilename
			'end if
			'fso.MoveFile filesource,newfilename
			'aa=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
			'2013/11/26修改可以中文檔名上傳及虛擬路徑
			strpath="/btbrt/" & session("se_branch") & "T/temp"
			attach_name = filename & "." & right(aa,len(aa)-InstrRev(aa,"."))	'重新命名檔名
			newfilename = strpath & "/" & attach_name	'存在資料庫路徑
			call renameFile_nobackup(strpath,aa,attach_name)
		end if 
	end if
	'If Request("tfy_case_stat") <> "OO" then    
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
			        " class_count = '" & request("tfzr_class_count") & "'," & _
			        " class_type = '" & request("tfzr_class_type") & "',"
		sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
		sql = left(sql,len(sql)-1) & sqlWHERE   
		cmd.CommandText=SQL
		If Trim(Request("chkTest"))<>Empty Then Response.Write "38=" & SQL & "<hr>"
		cmd.Execute(SQL)
	'else
	'	sql = "UPDATE dmt_temp SET agt_no='"& request("tfzd_agt_no") &"' ,remark1 = " & pkStr(Request("tfzd_remark1"),"")
	'	sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
	'	SQL=sql & sqlwhere
	'	cmd.CommandText=SQL
	'	cmd.Execute(SQL)
	'End if	
'商品類別	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("in_scode") & "','" & request("in_no") & "',0,'"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "39=" & SQL6 & "<hr>"
					cmd.Execute(SQL6)
				END IF
		next
	 End IF		

'新增展覽優先權
shownum=request("shownum_dmt")
	if shownum>0 then
	   for i=1 to shownum
	       if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
				isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
				isql=isql & "'" & request("in_no") & "',0," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
				'Response.Write "insert-casedmt_show="&isql&"<br>"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "40=" & iSQL & "<hr>"
				Conn.Execute(isql)
		   end if		
	   next
	end if
		
'*****移轉檔	
	'dmt_tran入log
	call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode")))
	sql = "UPDATE dmt_tran SET "   
	sqlWhere = ""
	for each x in request.form
	     if mid(x,2,3) = "fg" & ntag then				 
	    			select case left(x,1)		       
						 case "d"
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
						 case "n"
							 sql = sql & " " & mid(x,6) & "=" & drn(x)
						 case else
							 if x="tfg1_seq" then
								sql = sql & " " & mid(x,6) & "=" & drn(x)
							 else
							 sql = sql & " " & mid(x,6) & "=" & pkStr(request(x),",")
							 end if
					 end select
	     end if
  next
  if request("O_item1") <>empty or Request("O_item2") <>empty then
		 sql = sql & " other_item = '" & Request("O_item1") & ";" & Request("O_item2") & "'," 	
  end if
  if request("other_item2")<>empty then
     sql=sql & "other_item2="
     if request("other_item2t")<>empty then
        sql = sql & " '" & request("other_item2") & "," & trim(request("other_iterm2t")) & "',"
     else
		sql = sql & " '" & request("other_item2") & "',"   
     end if   
  end if	
  sql = sql & " tr_date  = '" & date() & "'," & _
			  " tr_scode = '" & session("se_scode") & "',"
  sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
  sql = left(sql,len(sql)-1) & sqlWHERE  
  cmd.CommandText=SQL
  If Trim(Request("chkTest"))<>Empty Then Response.Write "41=" & SQL & "<hr>"
  cmd.Execute(SQL)
  
 '*****新增案件異動明細檔，關係人資料	
    dsql="delete from dmt_tranlist where in_no='" & trim(request("in_no")) & "' and in_scode='" & trim(request("in_scode")) & "' and mod_field='mod_ap'"
    cmd.CommandText=dSQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "42=" & dSQL & "<hr>"
	cmd.Execute(dSQL)
	for k=1 to request("fl_apnum")
		 ocname1 = replace(trim(request("tfr_ocname1_" & k)),"'","’")
		 if instr(ocname1,"&#") > 0 then
		 else
			ocname1 = replace(ocname1,"&","＆")
		 end if
		 ocname2 = replace(trim(request("tfr_ocname2_" & k)),"'","’")
		 if instr(ocname2,"&#") > 0 then
		 else
			ocname2 = replace(ocname2,"&","＆")
		 end if	
		 oename1 = replace(trim(request("tfr_oename1_" & k)),"'","’")
		 if instr(oename1,"&#") > 0 then
		 else
			oename1 = replace(oename1,"&","＆")
		 end if	
		 oename2 = replace(trim(request("tfr_oename2_" & k)),"'","’")
		 if instr(oename2,"&#") > 0 then
		 else
			oename2 = replace(oename2,"&","＆")
		 end if	
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2,"
         sql3=sql3 & "ocrep,oerep,ozip,oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,oapclass,oap_country,"
         sql3=sql3 & "tran_code) values('" & request("in_scode") & "','" & request("in_no") & "','mod_ap','" & request("tfr_old_no"&k) & "'"
         sql3=sql3 & ",'" & ocname1 & "','" & ocname2 & "','" & oename1 & "','" & oename2 & "','" & trim(request("tfr_ocrep"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oerep"&k)) & "','" & trim(request("tfr_ozip"&k)) & "','" & trim(request("tfr_oaddr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oaddr2_"&k)) & "','" & trim(request("tfr_oeaddr1_" & k)) & "','" & trim(request("tfr_oeaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oeaddr3_"&k)) & "','" & trim(request("tfr_oeaddr4_"&k)) & "','" & trim(request("tfr_otel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_otel"&k)) & "','" & trim(request("otel1_"&k)) & "','" & trim(request("ofax"&k)) & "','" & trim(request("tfr_oapclass"&k)) & "','" & trim(request("tfr_oap_country"&k)) & "','N')"
		 cmd.CommandText=SQL3	
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "43=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)    
	 next    

''*****新增案件異動明細檔	
if Arcase="FL1" or arcase="FL5" then
		for i=1 to request("ctrlnum2")
			sql = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark) "
			sql = sql & "VALUES('" & Request("in_scode") & "','" & Request("in_no") & "','mod_class','"&request("tfl1_mod_type")&"','"&request("mod_count")&"','"&request("mod_dclass")&"','"&request("new_no"&i)&"','"&request("list_remark"&i)&"')"
			cmd.CommandText=SQL
			If Trim(Request("chkTest"))<>Empty Then Response.Write "44=" & SQL & "<hr>"
			cmd.Execute(SQL)
		next 
elseif Arcase="FL2" or arcase="FL6" then
		for i=1 to request("ctrlnum2")
			sql = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark) "
			sql = sql & "VALUES('" & Request("in_scode") & "','" & Request("in_no") & "','mod_class','"&request("tfl1_mod_type")&"','"&request("mod_count")&"','"&request("mod_dclass")&"','"&request("new_no"&i)&"','"&request("list_remark"&i)&"')"
			cmd.CommandText=SQL
			If Trim(Request("chkTest"))<>Empty Then Response.Write "45=" & SQL & "<hr>"
			cmd.Execute(SQL)
		next 
	'*****商標權人資料	
	 dsql="delete from dmt_tranlist where in_no='" & trim(request("in_no")) & "' and in_scode='" & trim(request("in_scode")) & "' and mod_field='mod_tap'"
    cmd.CommandText=dSQL
	If Trim(Request("chkTest"))<>Empty Then Response.Write "46=" & dSQL & "<hr>"
	cmd.Execute(dSQL) 	
	for k=1 to request("fl2_apnum")
		 ncname1 = replace(trim(request("tfv_ncname1_" & k)),"'","’")
		 if instr(ncname1,"&#") > 0 then
		 else
			ncname1 = replace(ncname1,"&","＆")
		 end if	
		 ncname2 = replace(trim(request("tfv_ncname2_" & k)),"'","’")
		 if instr(ncname2,"&#") > 0 then
		 else
			ncname2 = replace(ncname2,"&","＆")
		 end if	
		 nename1 = replace(trim(request("tfv_nename1_" & k)),"'","’")
		 if instr(nename1,"&#") > 0 then
		 else
			nename1 = replace(nename1,"&","＆")
		 end if	
		 nename2 = replace(trim(request("tfv_nename2_" & k)),"'","’")
		 if instr(nename2,"&#") > 0 then
		 else
			nename2 = replace(nename2,"&","＆")
		 end if	
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,new_no,ncname1,ncname2,nename1,nename2,"
         sql3=sql3 & "ncrep,nerep,nzip,naddr1,naddr2,neaddr1,neaddr2,neaddr3,neaddr4,ntel0,ntel,ntel1,nfax,napclass,nap_country,"
         sql3=sql3 & "tran_code) values('" & request("in_scode") & "','" & request("in_no") & "','mod_tap','" & request("tfv_new_no"&k) & "'"
         sql3=sql3 & ",'" & ncname1 & "','" & ncname2 & "','" & nename1 & "','" & nename2 & "','" & trim(request("tfv_ncrep"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_nerep"&k)) & "','" & trim(request("tfv_nzip"&k)) & "','" & trim(request("tfv_naddr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_naddr2_"&k)) & "','" & trim(request("tfv_neaddr1_" & k)) & "','" & trim(request("tfv_neaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_neaddr3_"&k)) & "','" & trim(request("tfv_neaddr4_"&k)) & "','" & trim(request("tfv_ntel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfv_ntel"&k)) & "','" & trim(request("tfv_ntel1_"&k)) & "','" & trim(request("tfv_nfax"&k)) & "','" & trim(request("tfv_napclass"&k)) & "','" & trim(request("tfv_nap_country"&k)) & "','N')"
		 cmd.CommandText=SQL3	
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "47=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)    
	 next    
end if
'Response.End
'申請人入log_table
 call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
 dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=0"
 cmd.CommandText=dSQL7
 If Trim(Request("chkTest"))<>Empty Then Response.Write "48=" & dSQL7 & "<hr>"
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
			If Trim(Request("chkTest"))<>Empty Then Response.Write "49=" & SQL7 & "<hr>"
			cmd.Execute(SQL7)
		End IF
		'Response.Write "apnum="&SQL7&"<br>"
next
'*****新增文件上傳
	call updmt_attach_forcase(cnn,tprgid,request("in_no"))
'	'入dmt_attach_log
'	call insert_log_table(conn,"U",tprgid,"dmt_attach","in_no",request("in_no"))
'	'***先清掉所有文件上傳資料	
 '   sql="Delete from dmt_attach where in_no = '" & request("In_no") & "'" 
  '  cmd.CommandText=SQL
'    cmd.Execute(SQL)   
'	strpath="/btbrt/" & session("se_branch") & "T/"  & request("attach_path")
'	for k=1 to request("attachfilenum")
'		if trim(request("attach_name"&k))<>empty then
'		    straa=request("attach_name"&k)	'上傳檔名
'			attach_name = request("in_no") & "-" & k & "." & right(straa,len(straa)-InstrRev(straa,"."))	'重新命名檔名
'			newattach_path = strpath & "/" & attach_name	'存在資料庫路徑
'			if request("attach_flag"&k) = "A" then
'				call renameFile(strpath,strpath,straa,attach_name)
'				source_name=straa
'			else
'				source_name=request("source_name"&k)
'			end if	
'			sqlattach="insert into dmt_attach(seq,seq1,case_no,in_no,source,in_date,in_scode,attach_no,attach_path,doc_type,attach_desc,attach_name,source_name,attach_size,attach_flag,attach_branch,tran_date,tran_scode) values(" _
'		             & chknull(request("tfzb_seq")) & "," & pkstr(request("tfzb_seq1"),",") & pkstr(request("attach_case_no"),",") & pkstr(request("in_no"),",") & "'case',getdate()," & pkstr(session("se_scode"),",") & k & "," _
'		             & pkstr(newattach_path,",") & pkstr(request("doc_type"&k),",") & pkstr(trim(request("attach_desc"&k)),",") & pkstr(trim(attach_name),",") & pkstr(source_name,",") & pkstr(request("attach_size"&k),",") _
'		             & "'" & request("attach_flag"&k) & "','" & request("attach_branch"&k) & "',getdate(),'" & session("se_scode") & "')"
'		              
'		else
'			sqlattach=""
'		end if
''		Response.Write sqlattach
''		Response.End
'		if sqlattach<>"" then
'		   cmd.CommandText=sqlattach
'		   cmd.Execute(sqlattach)	
'		end if
'	next 		
' Response.End
  '後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   cmd.CommandText=SQL4	
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "50=" & SQL4 & "<hr>"
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
		If Trim(Request("chkTest"))<>Empty Then Response.Write "51=" & SQL & "<hr>"
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
