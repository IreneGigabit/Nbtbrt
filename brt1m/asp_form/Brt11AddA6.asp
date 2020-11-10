<%
sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set RSreg=Server.CreateObject("ADODB.recordset")
set RCreg=Server.CreateObject("ADODB.recordset")
set RBreg=Server.CreateObject("ADODB.recordset")

conn.BeginTrans	
'******************產生流水號

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"

	//寫入case_dmt
	insert_case_dmt(conn, RSno);


if arcase="FC11" or arcase="FC5" or arcase="FC7" or arcase="FCH" then
	if request("nfy_tot_num")<>empty then
		for i=2 to request("nfy_tot_num")
			if trim(request("dseqa"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&RSno&"',"&trim(request("dseqa"&i))&",'"&trim(request("dseq1a"&i))&"',"&trim(request("dseqa"&i))&",'"&trim(request("dseq1a"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqa"&i))<>empty then
					dseqa=trim(request("dseqa"&i))
				Else
					dseqa="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,cseq,cseq1,case_stat1)"
				SQL = SQL & "values ('"&RSno&"',"&dseqa&",'"&trim(request("dseq1a"&i))&"',"&dseqa&",'"&trim(request("dseq1a"&i))&"','NN')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & SQL & "<hr>"
				Conn.Execute(SQL)
			End IF
			SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1 "
			RSreg.open sqlno,conn,1,1
			Case_sqlno=trim(RSreg("case_sqlno"))
			RSreg.close
			if trim(request("dseqa"&i))=empty then
				SQL3="SELECT * FROM  dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
				RCreg.open SQL3,conn,1,1
				IF not RCreg.EOF Then
				filepath="/btbrt/" & session("se_branch") & "t/temp"
				'Response.Write filepath
				filename = RSno&"-FC"&i
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
							sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & RSno & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &",'"&trim(request("dseq1a"&i))&"',"
							SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
							'Response.Write "SQL7:"&SQL7&"<br><br><br><br>"
							'Response.End
							If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & SQL7 & "<hr>"
							Conn.execute(SQL7)
							'*****申請人檔
							for apnum=1 to trim(request("apnum"))
								ap_cname = replace(trim(request("tfzp_ap_cname" & apnum)),"'","’")
								if len(ap_cname) > 0 then
									if instr(ap_cname,"&#") > 0 then
									else
										ap_cname = replace(ap_cname,"&","＆")
									end if
								end if
								ap_cname1 = replace(trim(request("dbmn1_ncname1_" & apnum)),"'","’")
								if len(ap_cname1) > 0 then
									if instr(ap_cname1,"&#") > 0 then
									else
										ap_cname1 = replace(ap_cname1,"&","＆")
									end if
								end if
								ap_cname2 = replace(trim(request("dbmn1_ncname2_" & apnum)),"'","’")
								if len(ap_cname2) > 0 then
									if instr(ap_cname2,"&#") > 0 then
									else
										ap_cname2 = replace(ap_cname2,"&","＆")
									end if
								end if
								ap_ename = replace(trim(request("tfzp_ap_ename" & apnum)),"'","’")
								if len(ap_ename) > 0 then
									if instr(ap_ename,"&#") > 0 then
									else
										ap_ename = replace(ap_ename,"&","＆")
									end if
								end if
								ap_ename1 = replace(trim(request("dbmn1_nename1_" & apnum)),"'","’")
								if len(ap_ename1) > 0 then
									if instr(ap_ename1,"&#") > 0 then
									else
										ap_ename1 = replace(ap_ename1,"&","＆")
									end if
								end if
								ap_ename2 = replace(trim(request("dbmn1_nename2_" & apnum)),"'","’")
								if len(ap_ename2) > 0 then
									if instr(ap_ename2,"&#") > 0 then
									else
										ap_ename2 = replace(ap_ename2,"&","＆")
									end if
								end if
								ap_fcname = replace(trim(request("dbmn1_fcname_" & apnum)),"'","’")
								if len(ap_fcname) > 0 then
									if instr(ap_fcname,"&#") > 0 then
									else
										ap_fcname = replace(ap_fcname,"&","＆")
									end if
								end if
								ap_lcname = replace(trim(request("dbmn1_lcname_" & apnum)),"'","’")
								if len(ap_lcname) > 0 then
									if instr(ap_lcname,"&#") > 0 then
									else
										ap_lcname = replace(ap_lcname,"&","＆")
									end if
								end if
								ap_fename = replace(trim(request("dbmn1_fename_" & apnum)),"'","’")
								if len(ap_fename) > 0 then
									if instr(ap_fename,"&#") > 0 then
									else
										ap_fename = replace(ap_fename,"&","＆")
									end if
								end if
								ap_lename = replace(trim(request("dbmn1_lename_" & apnum)),"'","’")
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
								SQL7 = SQL7 & "'"& RSno &"'," & case_sqlno & ",'"& trim(request("dbmn1_apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
								SQL7 = SQL7 & ",'"& trim(request("dbmn1_new_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
								SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
								SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
								SQL7 = SQL7 & "," & chkzero(request("dbmn1_ap_sql"&apnum),2) & ",'" & trim(request("dbmn1_nzip"&apnum)) & "','" & trim(request("dbmn1_naddr1_"&apnum)) & "','" & trim(request("dbmn1_naddr2_"&apnum)) & "'"
								SQL7 = SQL7 & ",'" & trim(request("dbmn1_neaddr1_"&apnum)) & "','" & trim(request("dbmn1_neaddr2_"&apnum)) & "','" & trim(request("dbmn1_neaddr3_"&apnum)) & "','" & trim(request("dbmn1_neaddr4_"&apnum)) & "')" 
								Response.Write "SQL_FC5申請人="&SQL7&"<br>"
								If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & SQL7 & "<hr>"
								Conn.Execute(SQL7)
								
							next
							
					End IF
					RCreg.Close
				'商品類別	
				SQLno="SELECT *  FROM casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
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
						'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
				'展覽會優先權	
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
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
							If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
			End IF
		next
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "10=" & SQL & "<hr>"
		Conn.execute(SQL)
	End IF
elseif arcase="FC21" or arcase="FC6" or arcase="FC8" or arcase="FCI" then
	if request("nfy_tot_num")<>empty then
		for i=2 to request("nfy_tot_num")
			if trim(request("dseqb"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&RSno&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "11=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqb"&i))<>empty then
					dseqb=trim(request("dseqb"&i))
				Else
					dseqb="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&RSno&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"','NN')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "12=" & SQL & "<hr>"
				Conn.Execute(SQL)
			End IF
			SQLno="SELECT MAX(case_sqlno) AS case_sqlno FROM case_dmt1 "
			RSreg.open sqlno,conn,1,1
			Case_sqlno=trim(RSreg("case_sqlno"))
			RSreg.close
			if trim(request("dseqb"&i))=empty then
				SQL3="SELECT * FROM  dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
				RCreg.open SQL3,conn,1,1
				IF not RCreg.EOF Then
				filepath="/btbrt/" & session("se_branch") & "t/temp"
				'Response.Write filepath
				filename = RSno&"-FC"&i
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
									sqlValue=sqlValue& "'"&Trim(RCreg("S_mark2"))&"',"
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
							for apnum=1 to trim(request("fc0_apnum"))
								ap_cname = replace(trim(request("dbmn_ap_cname" & apnum)),"'","’")
								if len(ap_cname) > 0 then
									if instr(ap_cname,"&#") > 0 then
									else
										ap_cname = replace(ap_cname,"&","＆")
									end if
								end if
								ap_cname1 = replace(trim(request("dbmn_ncname1_" & apnum)),"'","’")
								if len(ap_cname1) > 0 then
									if instr(ap_cname1,"&#") > 0 then
									else
										ap_cname1 = replace(ap_cname1,"&","＆")
									end if
								end if
								ap_cname2 = replace(trim(request("dbmn_ncname2_" & apnum)),"'","’")
								if len(ap_cname2) > 0 then
									if instr(ap_cname2,"&#") > 0 then
									else
										ap_cname2 = replace(ap_cname2,"&","＆")
									end if
								end if
								ap_ename = replace(trim(request("dbmn_ap_ename" & apnum)),"'","’")
								if len(ap_ename) > 0 then
									if instr(ap_ename,"&#") > 0 then
									else
										ap_ename = replace(ap_ename,"&","＆")
									end if
								end if
								ap_ename1 = replace(trim(request("dbmn_nename1_" & apnum)),"'","’")
								if len(ap_ename1) > 0 then
									if instr(ap_ename1,"&#") > 0 then
									else
										ap_ename1 = replace(ap_ename1,"&","＆")
									end if
								end if
								ap_ename2 = replace(trim(request("dbmn_nename2_" & apnum)),"'","’")
								if len(ap_ename2) > 0 then
									if instr(ap_ename2,"&#") > 0 then
									else
										ap_ename2 = replace(ap_ename2,"&","＆")
									end if
								end if
								ap_fcname = replace(trim(request("dbmn_fcname_" & apnum)),"'","’")
								if len(ap_fcname) > 0 then
									if instr(ap_fcname,"&#") > 0 then
									else
										ap_fcname = replace(ap_fcname,"&","＆")
									end if
								end if
								ap_lcname = replace(trim(request("dbmn_lcname_" & apnum)),"'","’")
								if len(ap_lcname) > 0 then
									if instr(ap_lcname,"&#") > 0 then
									else
										ap_lcname = replace(ap_lcname,"&","＆")
									end if
								end if
								ap_fename = replace(trim(request("dbmn_fename_" & apnum)),"'","’")
								if len(ap_fename) > 0 then
									if instr(ap_fename,"&#") > 0 then
									else
										ap_fename = replace(ap_fename,"&","＆")
									end if
								end if
								ap_lename = replace(trim(request("dbmn_lename_" & apnum)),"'","’")
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
								SQL7 = SQL7 & "'"& RSno &"'," & case_sqlno & ",'"& trim(request("dbmn_apsqlno"& apnum)) &"','"& trim(request("fc0_ap_server_flag" & apnum)) &"'"
								SQL7 = SQL7 & ",'"& trim(request("dbmn_new_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
								SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
								SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
								SQL7 = SQL7 & "," & chkzero(request("dbmn_ap_sql"&apnum),2) & ",'" & trim(request("dbmn_nzip"&apnum)) & "','" & trim(request("dbmn_naddr1_"&apnum)) & "','" & trim(request("dbmn_naddr2_"&apnum)) & "'"
								SQL7 = SQL7 & ",'" & trim(request("dbmn_neaddr1_"&apnum)) & "','" & trim(request("dbmn_neaddr2_"&apnum)) & "','" & trim(request("dbmn_neaddr3_"&apnum)) & "','" & trim(request("dbmn_neaddr4_"&apnum)) & "')" 
								Response.Write "SQL_FC6申請人="&SQL7&"<br>"
								If Trim(Request("chkTest"))<>Empty Then Response.Write "14=" & SQL7 & "<hr>"
								Conn.Execute(SQL7)
								
							next
					End IF
					RCreg.Close
				'商品類別	
				SQLno="SELECT *  FROM casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
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
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
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
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL & "<hr>"
		Conn.execute(SQL)
	End IF
End IF
	
	//寫入接洽費用檔
	insert_caseitem_dmt(conn, RSno);

	//寫入dmt_temp
	insert_dmt_temp(conn, RSno);
			
	//寫入商品類別檔
	insert_casedmt_good(conn, RSno);

            //****新增展覽優先權資料
            insert_casedmt_show(conn, RSno,"0");

	'*****新增案件變更檔
	select case left(Request("tfy_arcase"),4)
		case "FC1&","FC10","FC11","FC5&","FC7&","FC9&","FCA&","FCB&","FCF&","FCH&":%><!--#include file="caseForm/AddFC1.inc"-->
		<%case "FC2&","FC20","FC21","FC0&","FC6&","FC8&","FCC&","FCD&","FCG&","FCI&":%><!--#include file="caseForm/AddFC2.inc"-->
		<%case "FC3&":%><!--#include file="caseForm/AddFC3.inc"-->
		<%case "FC4&":%><!--#include file="caseForm/AddFC4.inc"-->
<%end select				 


	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

	//後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//更新客戶主檔最近立案日
	upd_dmt_date(conn, RSno);
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		conn.RollbackTrans
		Response.Write "conn.RollbackTrans...<br>"
		Response.End
	End If
	Conn.CommitTrans
End sub
%>

<!--#include file="CaseForm/ShowDoneBox.inc"-->