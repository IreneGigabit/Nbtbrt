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
	filename = RSno
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
				'newfilename = trim(request("draw_file"))
				'舊案移轉抓取到舊案路徑，複製下一筆會有問題
				 fseq= right("00000"&request("tfzd_ref_no"),5)
				 draw_strpath="/btbrt/" & session("se_branch") & "t/" & left(fseq,1) & "/" & mid(fseq,2,2)
		         draw_strpath1="/btbrt/" & session("se_branch") & "t/temp"
		         'draw_attach_name=mid(request("Draw_file"),instrrev(request("Draw_file"),"\")+1)
		         draw_attach_name=mid(request("Draw_file"),instrrev(request("Draw_file"),"/")+1)
		         draw_newfilename=filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
		         call copynamefile(draw_strpath,draw_strpath1,draw_attach_name,draw_newfilename)
		         'newfilename = server.MapPath(draw_strpath1) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
		         newfilename = draw_strpath1 & "/" & draw_newfilename	'存在資料庫路徑
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
	'****新舊案移轉新增至案件檔	
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
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					cmd.CommandText=SQL6
					If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & SQL6 & "<hr>"
					cmd.Execute(SQL6)
				END IF
		next
	 End IF	

            //****新增展覽優先權資料
            insert_casedmt_show(conn, RSno);

'*****新增案件移轉檔	 
	sql = "INSERT INTO dmt_tran("
				sqlValue = ") VALUES("
				for each x in request.form
					if request(x) <> "" then
						if mid(x,1,4) = "tfg1" then
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
	 if request("O_item1") <>empty or Request("O_item2") <>empty then
		 SQL=SQL & "other_item,"
		 sqlvalue = sqlvalue & " '" & Request("O_item1") & ";" & Request("O_item2") & "',"
	end if			
	 SQL=SQL & "in_scode, in_no,tr_date,tr_scode,"
	 sqlvalue = sqlvalue & " '" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & session("se_scode") & "',"	
	 SQL3 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
	  
	 'Response.Write "SQL_dmt_tran="&SQL3&"<br><br><br><br>" 
	 cmd.CommandText=SQL3
	 If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & SQL3 & "<hr>"
	 cmd.Execute(SQL3)

'*****新增案件異動明細檔，關係人資料	 
     for k=1 to request("ft_apnum")
		 ocname1 = replace(trim(request("tfr_ocname1_" & k)),"'","’")
		 ocname1 = replace(ocname1,"&","＆")
		 ocname2 = replace(trim(request("tfr_ocname2_" & k)),"'","’")
		 ocname2 = replace(ocname2,"&","＆")
		 oename1 = replace(trim(request("tfr_oename1_" & k)),"'","’")
		 oename1 = replace(oename1,"&","＆")
		 oename2 = replace(trim(request("tfr_oename2_" & k)),"'","’")
		 oename2 = replace(oename2,"&","＆")
         sql3="insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2,"
         sql3=sql3 & "ocrep,oerep,ozip,oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,otel0,otel,otel1,ofax,"
         sql3=sql3 & "tran_code) values('" & request("F_tscode") & "','" & RSno & "','mod_ap','" & request("tfr_old_no"&k) & "'"
         sql3=sql3 & ",'" & ocname1 & "','" & ocname2 & "','" & oename1 & "','" & oename2 & "','" & trim(request("tfr_ocrep"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oerep"&k)) & "','" & trim(request("tfr_ozip"&k)) & "','" & trim(request("tfr_oaddr1_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oaddr2_"&k)) & "','" & trim(request("tfr_oeaddr1_" & k)) & "','" & trim(request("tfr_oeaddr2_" & k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_oeaddr3_"&k)) & "','" & trim(request("tfr_oeaddr4_"&k)) & "','" & trim(request("tfr_otel0_"&k)) & "',"
         sql3=sql3 & "'" & trim(request("tfr_otel"&k)) & "','" & trim(request("otel1_"&k)) & "','" & trim(request("ofax"&k)) & "','N')"
		 cmd.CommandText=SQL3	
		 Response.Write "SQL_dmt_tranlist="&SQL3&"<br>"
'		 Response.End
	     If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & SQL3 & "<hr>"
		 cmd.Execute(SQL3)    
	 next    
	 
'	 Response.End
	 
	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

'移轉多件入檔	
if arcase="FT2" then
	if request("nfy_tot_num")<>empty then
		for i=2 to request("nfy_tot_num")
			if trim(request("dseqb"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&RSno&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"',"&trim(request("dmseqb"&i))&",'"&trim(request("dmseq1b"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "11=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqb"&i))<>empty then
					dseqb=trim(request("dseqb"&i))
				Else
					dseqb="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&RSno&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"','"& trim(request("dmseqb"&i)) &"','"&trim(request("dmseq1b"&i))&"','NN')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "12=" & SQL & "<hr>"
				Conn.Execute(SQL)
			End IF
			SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1 "
			rsi.open sqlno,conn,1,1
			Case_sqlno=trim(rsi("case_sqlno"))
			rsi.close
			if trim(request("dseqb"&i))=empty then
				SQL3="SELECT * FROM  dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='T'"
				RCreg.open SQL3,conn,1,1
				IF not RCreg.EOF Then
					filepath="/btbrt/" & session("se_branch") & "t/temp"
					'Response.Write filepath
					filename = RSno&"-FT"&i
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
							sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &",'"&trim(request("dseq1b"&i))&"',"
							SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
							'Response.Write "SQL7:"&SQL7&"<br><br><br><br>"
							'Response.End
							If Trim(Request("chkTest"))<>Empty Then Response.Write "13=" & SQL7 & "<hr>"
							Conn.execute(SQL7)

							'申請人資料畫面Apcust_FC_RE_form.inc
							'*****申請人檔
							insert_dmt_temp_ap(conn, RSno,case_sqlno);	
				End IF
				RCreg.Close
				'商品類別	
				SQLno="SELECT *  FROM casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='T'"
				RCreg.open sqlno,conn,1,1
				IF not RCreg.EOF then
					For x=1 to RCreg.RecordCount
						if trim(RCreg("class"))<>empty or trim(RCreg("dmt_goodname"))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
							SQL6 = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
							SQL6=SQL6&"('" & request("F_tscode") & "','" & RSno & "',"&case_sqlno&",'"&trim(RCreg("class"))&"','"&trim(RCreg("dmt_grp_code"))&"'"
							SQL6=SQL6&",'"&trim(RCreg("dmt_goodname"))&"','"&trim(RCreg("dmt_goodcount"))&"',"
							SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
				'展覽會優先權	
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"' and mark='T'"
				SQLno=SQLno & " order by show_no "
				RCreg.open sqlno,conn,1,1
				IF not RCreg.EOF then
					For x=1 to RCreg.RecordCount
						if trim(RCreg("show_date"))<>empty or trim(RCreg("show_name"))<>empty then
							SQL6 = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values"
							SQL6=SQL6&"('" & RSno & "',"&case_sqlno&",'"&trim(RCreg("show_date"))&"','"&trim(RCreg("show_name"))&"'"
							SQL6=SQL6&",getdate(),'" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						Response.Write "SQL6_casedmt_show="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
			End IF
		next
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='T'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='T'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark='T'"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL & "<hr>"
		Conn.execute(SQL)
	End IF
End IF	

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