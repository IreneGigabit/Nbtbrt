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
			SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,"
			sqlvalue= sqlvalue & " '" & request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"	
				  
			SQL = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
			
			cmd.CommandText=SQL
			If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & SQL & "<hr>"
			cmd.Execute(SQL)	
			
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

if arcase="FP1" then
	save1="tfg1"	'欄位開頭
	save2="tfr1"
	lapnum=request("ft_apnum")
elseif arcase="FP2" then
	save1="tfg2"
	'save2="tfr2"
	'lapnum=request("fp_apnum")
	'2012/10/10因應2012/7/1新申請書修改與FP1相同畫面
	save2="tfr1"
	lapnum=request("ft_apnum")
end if
	
'*****新增案件移轉檔	 
	sql = "INSERT INTO dmt_tran("
				sqlValue = ") VALUES("
				for each x in request.form
					if request(x) <> "" then
						if mid(x,1,4) = save1 then
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
	 'if request("O_item1") <> empty then		 
		 SQL=SQL & "other_item,"
		 sqlvalue = sqlvalue & " '" & Request("O_item1") & ";" & Request("O_item2") & "',"
	 'end if			
	 if request("O_item3") <> empty then		 
		 SQL=SQL & "other_item1,"
		 sqlvalue = sqlvalue & " '" & Request("O_item3") & ";" & Request("O_item4") & "',"
	 end if			
	 SQL=SQL & "in_scode, in_no,tr_date,tr_scode,"
	 sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & session("se_scode") & "',"	
	 SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
'Response.Write "新增案件移轉檔="&SQL3&"<br><br>"	  
'Response.End

	 cmd.CommandText=SQL3
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & SQL3 & "<hr>"
	 cmd.Execute(SQL3)

'*****新增案件異動明細檔,關係人
 	 for k=1 to lapnum
 		 Response.Write "a:"&save2&"<br>"
		 ocname1 = replace(trim(request(save2&"_ap_cname1_" & k)),"'","’")
		 ocname1 = replace(ocname1,"&","＆")
		 ocname2 = replace(trim(request(save2&"_ap_cname2_" & k)),"'","’")
		 ocname2 = replace(ocname2,"&","＆")
		 oename1 = replace(trim(request(save2&"_ap_ename1_" & k)),"'","’")
		 oename1 = replace(oename1,"&","＆")
		 oename2 = replace(trim(request(save2&"_ap_ename2_" & k)),"'","’")
		 oename2 = replace(oename2,"&","＆")
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2,"
         sql3=sql3 & "ocrep,oerep,ozip,oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,oapclass,oap_country,"
         sql3=sql3 & "tran_code) values('" & request("F_tscode") & "','" & RSno & "','mod_ap','" & request(save2&"_apcust_no"&k) & "'"
         sql3=sql3 & ",'" & ocname1 & "','" & ocname2 & "','" & oename1 & "','" & oename2 & "','" & trim(request(save2&"_ap_crep"&k)) & "',"
         sql3=sql3 & "'" & trim(request(save2&"_ap_erep"&k)) & "','" & trim(request(save2&"_ap_zip"&k)) & "','" & trim(request(save2&"_ap_addr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request(save2&"_ap_addr2_"&k)) & "','" & trim(request(save2&"_ap_eaddr1_" & k)) & "','" & trim(request(save2&"_ap_eaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request(save2&"_ap_eaddr3_"&k)) & "','" & trim(request(save2&"_ap_eaddr4_"&k)) & "','" & trim(request(save2&"_apatt_tel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request(save2&"_apatt_tel"&k)) & "','" & trim(request(save2&"_apatt_tel1_"&k)) & "','" & trim(request(save2&"_apatt_fax"&k)) & "','" & trim(request(save2&"_oapclass"&k)) & "','" & trim(request(save2&"_oap_country"&k)) & "','N')"
		 cmd.CommandText=SQL3	
		 'Response.Write "SQL_dmt_tranlist="&SQL3&"<br>"
		 'Response.End
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)    
	 next   

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