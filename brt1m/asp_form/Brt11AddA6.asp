<% 
Sub doUpdateDB()

'dmt_tranlist入log_table
call insert_log_table(conn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))	
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_tcnref'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_ap'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_apaddr'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_aprep'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from  dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_dmt'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_claim1'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_class' and mod_type='Dgood'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_agt'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from case_dmt1 where in_no='"& request("In_no") &"'" 
If Trim(Request("chkTest"))<>Empty Then Response.Write "10=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_temp where in_no='"& request("In_no") &"' and in_scode='"&request("in_scode")&"' and case_sqlno<>0" 
If Trim(Request("chkTest"))<>Empty Then Response.Write "11=" & stSQL & "<hr>"
Conn.Execute(stSQL)

select case left(trim(request("tfy_arcase")),4)
case "FC1&","FC10","FC9&","FCA&","FCB&","FCF&"
		case_stat=trim(request("tfy_case_stat"))
Case "FC11","FC5&","FC7&","FCH&"
		case_stat=trim(request("tfy_case_stat"))
case else
		case_stat=trim(request("tfy_case_stat"))
End Select

update_case_dmt();


if arcase="FC11" or arcase="FC5" or arcase="FC7" or arcase="FCH" then
	if request("nfy_tot_num")<>empty then
		for i=2 to request("nfy_tot_num")
			if trim(request("dseqa"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&trim(request("in_no"))&"',"&trim(request("dseqa"&i))&",'"&trim(request("dseq1a"&i))&"',"&trim(request("dseqa"&i))&",'"&trim(request("dseq1a"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "15=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqa"&i))<>empty then
					dseqa=trim(request("dseqa"&i))
				Else
					dseqa="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&trim(request("in_no"))&"',"&dseqa&",'"&trim(request("dseq1a"&i))&"',"&dseqa&",'"&trim(request("dseq1a"&i))&"','NN')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & SQL & "<hr>"
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
				filename = trim(request("in_no"))&"-FC"&i
				aa=trim(RCreg("draw_file"))
				if trim(aa) <> empty then
					IF ubound(split(trim(RCreg("draw_file")),"/"))=0 then
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
								IF trim(RCreg("S_mark2"))<>empty then
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
									'sql=sql&"Mseq1,"
'									sqlValue=sqlValue& "'_',"
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
							sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & Request("in_no") & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &",'"&trim(request("dseq1a"&i))&"',"
							SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
							'Response.Write "SQL7:"&SQL7&"<br>"
							'Response.End
							If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & SQL7 & "<hr>"
							Conn.execute(SQL7)
							'*****申請人檔
							call insert_log_table(Conn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";"&case_sqlno)
							dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=" & case_sqlno
							If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & dSQL7 & "<hr>"
							conn.Execute(dSQL7)
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
								SQL7 = SQL7 & "'"& request("in_no") &"'," & case_sqlno & ",'"& trim(request("dbmn1_apsqlno"& apnum)) &"','"& trim(request("ap_server_flag" & apnum)) &"'"
								SQL7 = SQL7 & ",'"& trim(request("dbmn1_new_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
								SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
								SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
								SQL7 = SQL7 & "," & chkzero(request("dbmn1_ap_sql"&apnum),2) & ",'" & trim(request("dbmn1_nzip"&apnum)) & "','" & trim(request("dbmn1_naddr1_"&apnum)) & "','" & trim(request("dbmn1_naddr2_"&apnum)) & "'"
								SQL7 = SQL7 & ",'" & trim(request("dbmn1_neaddr1_"&apnum)) & "','" & trim(request("dbmn1_neaddr2_"&apnum)) & "','" & trim(request("dbmn1_neaddr3_"&apnum)) & "','" & trim(request("dbmn1_neaddr4_"&apnum)) & "')" 
								'Response.Write "SQL_FC5申請人="&SQL7&"<br>"
								If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL7 & "<hr>"
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
							SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "',"&case_sqlno&",'"&trim(RCreg("class"))&"','"&trim(RCreg("dmt_grp_code"))&"'"
							SQL6=SQL6&",'"&trim(RCreg("dmt_goodname"))&"','"&trim(RCreg("dmt_goodcount"))&"',"
							SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "20=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
				'展覽優先權	
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
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
						'Response.Write "SQL6_casedmt_show="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "21=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
			End IF
		next
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "22=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "23=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "24=" & SQL & "<hr>"
		Conn.execute(SQL)
		'Response.End
	End IF
elseif arcase="FC21" or arcase="FC6" or arcase="FC8" or arcase="FCI" then
'Response.Write "1p:"&request("nfy_tot_num")&"<br><br><br>"

	if request("nfy_tot_num")<>empty then
		for i=2 to request("nfy_tot_num")
			if trim(request("dseqb"&i))<>empty then
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&trim(request("in_no"))&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"',"&trim(request("dseqb"&i))&",'"&trim(request("dseq1b"&i))&"','OO')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "25=" & SQL & "<hr>"
				Conn.Execute(SQL)
			Else
				IF trim(request("dseqb"&i))<>empty then
					dseqb=trim(request("dseqb"&i))
				Else
					dseqb="null"
				End IF
				SQL = "INSERT INTO case_dmt1(in_no,seq,seq1,Cseq,Cseq1,case_stat1)"
				SQL = SQL & "values ('"&trim(request("in_no"))&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"',"&dseqb&",'"&trim(request("dseq1b"&i))&"','NN')"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "26=" & SQL & "<hr>"
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
				filename = trim(request("in_no"))&"-FC"&i
				aa=trim(RCreg("draw_file"))
				if trim(aa) <> empty then
					'IF ubound(split(trim(RCreg("draw_file")),"\"))=0 then
					IF ubound(split(trim(RCreg("draw_file")),"/"))=0 then
						'filesource = server.MapPath(filepath) & "\" & aa 'temp
						'newfilename = server.MapPath(filepath) & "\" & filename & "." & right(aa,len(aa)-InstrRev(aa,"."))
						'if aa<>newfilename then
						'	if fso.FileExists(newfilename) then
						'		fso.DeleteFile newfilename
						'	end if
						'End IF
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
								IF trim(RCreg("S_mark2"))<>empty then
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
							'		sqlValue=sqlValue& "'_',"
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
							sqlValue = sqlvalue & " '" & trim(RCreg("class_type")) & "', '" & trim(RCreg("class_count")) & "','"&trim(RCreg("class"))&"',"
							SQL=SQL & "in_scode,in_no,In_date,draw_file,tr_date,tr_scode,case_sqlno,seq1,"
							sqlvalue= sqlvalue & "'" & Request("F_tscode") & "','" & Request("in_no") & "','" & date() & "','" & newfilename & "','" & date() & "','" & session("se_scode") & "',"& case_sqlno &",'"&trim(request("dseq1b"&i))&"',"
							SQL7 = left(sql,len(sql)-1) & left(sqlValue,len(sqlValue)-1) & ")"
							
							'Response.Write "SQL7:"&SQL7&"<br><br>"
							'Response.End
							If Trim(Request("chkTest"))<>Empty Then Response.Write "27=" & SQL7 & "<hr>"
							Conn.execute(SQL7)
							'申請人資料畫面Apcust_FC_RE_form.inc
							'*****申請人檔
							'if session("se_scode")="m802" then
							'   Response.Write trim(request("in_no"))&";"&case_sqlno
							'   Response.End
							'end if
							call insert_log_table(Conn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";"&case_sqlno)
							dSQL7="Delete dmt_temp_ap where in_no='"& trim(request("in_no")) &"' and case_sqlno=" & case_sqlno
							If Trim(Request("chkTest"))<>Empty Then Response.Write "28=" & dSQL7 & "<hr>"
							conn.Execute(dSQL7)
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
								SQL7 = SQL7 & "'"& request("in_no") &"'," & case_sqlno & ",'"& trim(request("dbmn_apsqlno"& apnum)) &"','"& trim(request("fc0_ap_server_flag" & apnum)) &"'"
								SQL7 = SQL7 & ",'"& trim(request("dbmn_new_no"& apnum)) &"','"& trim(ap_cname) &"','"&trim(ap_cname1)&"'"
								SQL7 = SQL7 & ",'"& trim(ap_cname2) &"','"& trim(ap_ename) &"','"&trim(ap_ename1)&"','"& trim(ap_ename2) &"'"
								SQL7 = SQL7 & ",getdate(),'"& session("se_scode") &"','" & ap_fcname & "','" & ap_lcname & "','" & ap_fename & "','" & ap_lename & "'"
								SQL7 = SQL7 & "," & chkzero(request("dbmn_ap_sql"&apnum),2) & ",'" & trim(request("dbmn_nzip"&apnum)) & "','" & trim(request("dbmn_naddr1_"&apnum)) & "','" & trim(request("dbmn_naddr2_"&apnum)) & "'"
								SQL7 = SQL7 & ",'" & trim(request("dbmn_neaddr1_"&apnum)) & "','" & trim(request("dbmn_neaddr2_"&apnum)) & "','" & trim(request("dbmn_neaddr3_"&apnum)) & "','" & trim(request("dbmn_neaddr4_"&apnum)) & "')" 
								'Response.Write "SQL_FC6申請人="&SQL7&"<br>"
								If Trim(Request("chkTest"))<>Empty Then Response.Write "29=" & SQL7 & "<hr>"
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
							SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "',"&case_sqlno&",'"&trim(RCreg("class"))&"','"&trim(RCreg("dmt_grp_code"))&"'"
							SQL6=SQL6&",'"&trim(RCreg("dmt_goodname"))&"','"&trim(RCreg("dmt_goodcount"))&"',"
							SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
						ELSE
							SQL6=""
						end if
						'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "30=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
				'展覽優先權	
				SQLno="SELECT *  FROM casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and num='"&i&"'"
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
						'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
						IF SQL6<>EMPTY THEN
							If Trim(Request("chkTest"))<>Empty Then Response.Write "31=" & SQL6 & "<hr>"
							Conn.Execute(SQL6)
						END IF
						RCreg.MoveNext
					Next
				End IF
				RCreg.Close
			End IF
		next
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "32=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "33=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "34=" & SQL & "<hr>"
		Conn.execute(SQL)
	End IF
End IF
 
update_dmt_temp();

insert_caseitem_dmt();


'商品類別
if left(arcase,3)<>"FC3" then	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','0','"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
		'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					If Trim(Request("chkTest"))<>Empty Then Response.Write "38=" & SQL6 & "<hr>"
					Conn.Execute(SQL6)
				END IF
		next
	 End IF	
else
	ctrlnum=trim(request("ctrlnum32"))
	IF trim(Request("tft3_class_count2"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class32"&x))<>empty or trim(request("good_name32"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & trim(Request("in_no")) & "','"&trim(request("class32"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name32"&x))&"','"&trim(request("good_count32"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
			'response.end
			
				IF SQL6<>EMPTY THEN
					If Trim(Request("chkTest"))<>Empty Then Response.Write "39=" & SQL6 & "<hr>"
					Conn.Execute(SQL6)
				END IF
		next
	 End IF
end if

'***新增展覽優先權資料
	
	shownum=request("shownum_dmt")
	if shownum>0 then
	   for i=1 to shownum
	       if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
				isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
				isql=isql & "'" & Request("in_no") & "',0," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
				'Response.Write "insert-casedmt_show="&isql&"<br>"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "40=" & iSQL & "<hr>"
				Conn.Execute(isql)
		   end if		
	   next
	end if
	
'Response.End
	 'dmt_tran入log
	call insert_log_table(conn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode")))    
	sql = "UPDATE dmt_tran SET "   
	sqlWhere = ""
	for each x in request.form
	     if mid(x,2,3) = "fg" & Num then	
			
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
  
  
 select case  left(trim(request("tfy_arcase")),4)
  case "FC21","FC6&","FC8&","FCI&"
		if request("O_item211") <>empty or Request("O_item221") <>empty then
			sql = sql & " other_item = '" & Request("O_item211") & ";" & Request("O_item221") & ";" & Request("O_item231") & "'," 	
		end if
		'2012/7/1新申請書增加修正使用規費書及質權移轉原因
		if request("tfop1_oitem1")="Y" then
			SQL=SQL & "other_item1='Y," & Request("tfop1_oitem1c") & "',"
		end if
		if request("tfop1_oitem2")="Y" then
			SQL=SQL & "other_item2='Y," & Request("tfop1_oitem2c") & "',"
		end if
  Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
		if request("O_item21") <>empty or Request("O_item22") <>empty then
		sql = sql & " other_item = '" & Request("O_item21") & ";" & Request("O_item22") & ";" & Request("O_item23") & "'," 	
		end if
		'2012/7/1新申請書增加修正使用規費書及質權移轉原因
		if request("tfop_oitem1")="Y" then
			SQL=SQL & "other_item1='Y," & Request("tfop_oitem1c") & "',"
		else
			SQL=SQL & "other_item1=null,"
		end if
		if request("tfop_oitem2")="Y" then
			SQL=SQL & "other_item2='Y," & Request("tfop_oitem2c") & "',"
		else
			SQL=SQL & "other_item2=null,"
		end if
  Case "FC3&"
    if request("O_item31") <>empty or Request("O_item32") <>empty then
		sql = sql & " other_item = '" & Request("O_item31") & ";" & Request("O_item32") & ";" & Request("O_item33") & "'," 	
	end if  
  End Select

  sql = sql & " tr_date  = '" & date() & "'," & _
			  " tr_scode = '" & session("se_scode") & "',"
  sql = sql & " seq = " & tfzb_seq & ","& _
		      " seq1 = '" & request("tfzb_seq1") & "',"	
  SQL=  sql & "in_scode = '" & request("F_tscode") & "',"	
  sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
  sql = left(sql,len(sql)-1) & sqlWHERE
' Response.Write SQL&"<br><br>"
'  Response.End
  If Trim(Request("chkTest"))<>Empty Then Response.Write "41=" & SQL & "<hr>"
  Conn.Execute(SQL)

	Select case left(request("tfy_Arcase"),4)	 
		case "FC1&","FC10","FC11","FC5&","FC7&","FC9&","FCA&","FCB&","FCF&","FCH&":%><!--#include file="caseForm/UpdateFC1.inc"--><%		
		case "FC2&","FC20","FC21","FC0&","FC6&","FC8&","FCC&","FCD&","FCG&","FCI&":%><!--#include file="caseForm/UpdateFC2.inc"--><%
		Case "FC3&":%><!--#include file="caseForm/UpdateFC3.inc"--><%
		Case "FC4&":%><!--#include file="caseForm/UpdateFC4.inc"--><%
	End Select	
'Response.End
 '*****文件上傳
	call updmt_attach_forcase(conn,tprgid,request("in_no"))

    '後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "42=" & SQL4 & "<hr>"
	   conn.Execute(SQL4)
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
		conn.RollbackTrans
		Response.Write "conn.RollbackTrans...<br>"
		Response.End
	End If
	Conn.CommitTrans  
End sub '---- doUpdateDB() ----


Sub doUpdateDB1(tno,tscode)
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	

'商品入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_good","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))      
stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and case_sqlno=0"
If Trim(Request("chkTest"))<>Empty Then Response.Write "43=" & stSQL & "<hr>"
Conn.Execute(stSQL)

'展覽優先權入log_table
call insert_log_table(cnn,"U",tprgid,"casedmt_show","in_no;case_sqlno",trim(request("in_no"))&";0")
stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno=0"
If Trim(Request("chkTest"))<>Empty Then Response.Write "44=" & stSQL & "<hr>"
conn.Execute(stSQL)

'dmt_tranlist入log_table
call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_tcnref'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "45=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_ap'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "46=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_apaddr'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "47=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_aprep'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "48=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from  dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_dmt'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "49=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_claim1'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "50=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_class' and mod_type='Dgood'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "51=" & stSQL & "<hr>"
Conn.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_agt'"
If Trim(Request("chkTest"))<>Empty Then Response.Write "52=" & stSQL & "<hr>"
Conn.Execute(stSQL)
'stSQL = "delete from case_dmt1 where in_no='"& request("In_no") &"'" 
'Conn.Execute(stSQL)
'stSQL = "delete from dmt_temp where in_no='"& request("In_no") &"' and in_scode='"&request("in_scode")&"' and case_sqlno<>0" 
'Conn.Execute(stSQL)
'stSQL = "delete from casedmt_good where in_no='"& request("In_no") &"' and in_scode='"&request("in_scode")&"' and case_sqlno<>0" 
'Conn.Execute(stSQL)


v=split(request("tfy_arcase"),"&")
arcase=v(0)
prt_code=v(1)

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
  If Trim(Request("chkTest"))<>Empty Then Response.Write "53=" & SQL & "<hr>"
  cmd.Execute(SQL)
 
if arcase="FC11" or arcase="FC5" or arcase="FC7" or arcase="FCH" then
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "54=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "55=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "56=" & SQL & "<hr>"
		Conn.execute(SQL)
elseif arcase="FC21" or arcase="FC6" or arcase="FC8" or arcase="FCI" then
		SQL="delete from dmt_temp_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "57=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_good_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "58=" & SQL & "<hr>"
		Conn.execute(SQL)
		SQL="delete from casedmt_show_change where in_scode='"&request("F_tscode")&"' and cust_area='"&request("F_cust_area")&"' and cust_seq='"&request("F_cust_seq")&"' and mark is null"
		If Trim(Request("chkTest"))<>Empty Then Response.Write "59=" & SQL & "<hr>"
		Conn.execute(SQL)
End IF
 
'******案件檔
'****圖檔上傳
	'將檔案更改檔名

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
	Select case left(request("tfy_arcase"),3)
	Case "FC9","FC1","FC5","FC7","FCA","FCB","FCF","FCH"
		Num="1"
	Case "FC2","FC0","FC6","FC8","FCC","FCD","FCG","FCI"
		Num="2"
	Case "FC3"
		Num="3"
	Case "FC4"
		Num="4"
	End Select
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
		
		'if case_stat="NA" then
		'sql = sql & " Mseq1 = '"& trim(request("tfzb_seq1")) &"',"& _
	    '	        " Mseq = "& trim(request("tfzb_seq")) &","
		'End iF
		sql = sql & " draw_file = " & pkstr(newfilename,",") & _
					" tr_date  = '" & date() & "'," & _
			        " tr_scode = '" & session("se_scode") & "',"
		if left(arcase,3)<>"FC3" then	
		sql = sql & " class = '" & request("tfzr_class") & "',"& _
			        " class_count = '" & request("tfzr_class_count") & "'," & _
			        " class_type = '" & request("tfzr_class_type") & "',"
		else
		sql = sql & " class = '" & request("tft3_class2") & "',"& _
			        " class_count = '" & request("tft3_class_count2") & "',"&_
			        " class_type = '" & request("tft3_class_type2") & "',"
		end if
		      
	    SQL=  sql & "in_scode = '" & request("F_tscode") & "',"
		sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "' and case_sqlno=0" 
		sql = left(sql,len(sql)-1) & sqlWHERE		  

		If Trim(Request("chkTest"))<>Empty Then Response.Write "60=" & SQL & "<hr>"
		Conn.Execute(SQL)
'Response.Write SQL&"<BR><BR>"
'Response.End

'	End if		
'商品類別
if left(arcase,3)<>"FC3" then	
	ctrlnum=trim(request("ctrlnum1"))
	IF trim(Request("tfzr_class_count"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class1"&x))<>empty or trim(request("good_name1"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & request("in_no") & "','0','"&trim(request("class1"&x))&"','"&trim(request("grp_code1"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name1"&x))&"','"&trim(request("good_count1"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
				IF SQL6<>EMPTY THEN
					If Trim(Request("chkTest"))<>Empty Then Response.Write "61=" & SQL6 & "<hr>"
					Conn.Execute(SQL6)
				END IF
		next
	 End IF	
else
	ctrlnum=trim(request("ctrlnum32"))
	IF trim(Request("tft3_class_count2"))<>empty then
		for x=1 to ctrlnum
			if trim(request("class32"&x))<>empty or trim(request("good_name32"&x))<>empty then '2015/10/21增加判斷若有商品也入，因證明標章及團體標章無類別但會有證明內容
				SQL6 = "INSERT INTO casedmt_good (in_scode,in_no,class,dmt_goodname,dmt_goodcount,tr_date,tr_scode) values"
				SQL6=SQL6&"('" & request("F_tscode") & "','" & trim(Request("in_no")) & "','"&trim(request("class32"&x))&"'"
				SQL6=SQL6&",'"&trim(request("good_name32"&x))&"','"&trim(request("good_count32"&x))&"',"
				SQL6=SQL6&"'" & date() & "','" & session("se_scode") & "')"
			ELSE
				SQL6=""
			end if
			'Response.Write "SQL6_casedmt_good="&SQL6&"<br><br><br>"
			'response.end
			
				IF SQL6<>EMPTY THEN
					If Trim(Request("chkTest"))<>Empty Then Response.Write "62=" & SQL6 & "<hr>"
					Conn.Execute(SQL6)
				END IF
		next
	 End IF
end if

'***新增展覽優先權資料
	
	shownum=request("shownum_dmt")
	if shownum>0 then
	   for i=1 to shownum
	       if trim(request("show_date_dmt"&i))<>empty or trim(request("show_name_dmt"&i))<>empty then
				isql="insert into casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) values ("
				isql=isql & "'" & Request("in_no") & "',0," & pkstr(request("show_date_dmt"&i),",") & pkstr(request("show_name_dmt"&i),",") & "getdate(),'" & session("se_scode") & "')"
				'Response.Write "insert-casedmt_show="&isql&"<br>"
				If Trim(Request("chkTest"))<>Empty Then Response.Write "63=" & iSQL & "<hr>"
				Conn.Execute(isql)
		   end if		
	   next
	end if
'Response.End
	'dmt_tran入log
	call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode")))    
	sql = "UPDATE dmt_tran SET "   
	sqlWhere = ""
	for each x in request.form
	     if mid(x,2,3) = "fg" & Num then			 
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
 
 
	 
 select case  left(trim(request("tfy_arcase")),4)
  case "FC21","FC6&","FC8&","FCI&"
		if request("O_item211") <>empty or Request("O_item221") <>empty then
			sql = sql & " other_item = '" & Request("O_item211") & ";" & Request("O_item221") & ";" & Request("O_item231") & "'," 	
		end if
		'2012/7/1新申請書增加修正使用規費書及質權移轉原因
		if request("tfop1_oitem1")="Y" then
			SQL=SQL & "other_item1=" & " 'Y," & Request("tfop1_oitem1c") & "',"
		end if
		if request("tfop1_oitem2")="Y" then
			SQL=SQL & "other_item2=" & " 'Y," & Request("tfop1_oitem2c") & "',"
		end if
  Case "FC2&","FC20","FC0&","FCC&","FCD&","FCG&"
		if request("O_item21") <>empty or Request("O_item22") <>empty then
		sql = sql & " other_item = '" & Request("O_item21") & ";" & Request("O_item22") & ";" & Request("O_item23") & "'," 	
		end if
		'2012/7/1新申請書增加修正使用規費書及質權移轉原因
		if request("tfop_oitem1")="Y" then
			SQL=SQL & "other_item1=" & " 'Y," & Request("tfop_oitem1c") & "',"
		end if
		if request("tfop_oitem2")="Y" then
			SQL=SQL & "other_item2=" & " 'Y," & Request("tfop_oitem2c") & "',"
		end if
  Case "FC3&"
    if request("O_item31") <>empty or Request("O_item32") <>empty then
		sql = sql & " other_item = '" & Request("O_item31") & ";" & Request("O_item32") & ";" & Request("O_item33") & "'," 	
	end if  
  End Select

  sql = sql & " tr_date  = '" & date() & "'," & _
			  " tr_scode = '" & session("se_scode") & "',"
  
  SQL=  sql & "in_scode = '" & request("F_tscode") & "',"	
  sqlWhere = " where in_scode = '" & request("in_scode") & "' and in_no = '" & request("In_no") & "'" 
  sql = left(sql,len(sql)-1) & sqlWHERE
  
  If Trim(Request("chkTest"))<>Empty Then Response.Write "64=" & SQL & "<hr>"
  Conn.Execute(SQL)
'Response.Write SQL&"<BR><BR>"

	Select case left(request("tfy_Arcase"),4)	 
		case "FC1&","FC10","FC11","FC5&","FC7&","FC9&","FCA&","FCB&","FCF&","FCH&":%><!--#include file="caseForm/UpdateFC1.inc"--><%		
		case "FC2&","FC20","FC21","FC0&","FC6&","FC8&","FCC&","FCD&","FCG&","FCI&":%><!--#include file="caseForm/UpdateFC2.inc"--><%
		Case "FC3&":%><!--#include file="caseForm/UpdateFC3.inc"--><%
		Case "FC4&":%><!--#include file="caseForm/UpdateFC4.inc"--><%
	End Select	
'*****文件上傳
	call updmt_attach_forcase(cnn,tprgid,request("in_no"))

  '後續交辦作業，更新營洽官方收文確認記錄檔grconf_dmt.job_no
	if trim(request("grconf_sqlno"))<>empty then
	   sql4 = "update grconf_dmt set job_no='" & request("in_no") & "',finish_date=getdate() where grconf_sqlno=" & request("grconf_sqlno")
	   If Trim(Request("chkTest"))<>Empty Then Response.Write "65=" & SQL4 & "<hr>"
	   conn.Execute(SQL4)
	End if
  SQL="select max(sqlno) as Msqlno from ToDoList where in_no = '" & tno & "' and in_scode = '" & tscode & "' and apcode='Si04W02' and dowhat='DC'"
   RTreg.Open sql,connsys,1,1,adcmdtext
   sqlno=RTreg("Msqlno")
   RTreg.close
   sql1="select * from todolist where sqlno = " & sqlno & " and branch='" & session("se_branch") & "'"
   RTreg.Open sql1,connsys,1,1,adcmdtext
   if not RTreg.EOF then				
   			
		SQLins="Insert into ToDoList (pre_sqlno,Branch,Syscode,Apcode,In_team,In_scode,In_no,Case_no,Step_date,dowhat,Job_scode,Job_status,mark) " & _
		       " values ('" & Mscode & "','" & RTreg("Branch") & "','" & RTreg("Syscode") & "','" & RTreg("Apcode") & "', '" & _
				RTreg("In_team") & "','" & RTreg("In_scode") & "','" & RTreg("In_no") & "','" & RTreg("Case_no") & "','" & _
				date() & "','DP','" & RTreg("job_scode") & "','NN'," &  pkstr(Request.Form("Mark"),")")
		sql=sqlins
		If Trim(Request("chkTest"))<>Empty Then Response.Write "66=" & SQL & "<hr>"
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
